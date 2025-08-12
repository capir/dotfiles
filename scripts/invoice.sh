#!/bin/bash

FILE="invoices.txt"
HEADER="date|invoice_id|amount|status|notes"

ensure_file() {
  if [ ! -f "$FILE" ]; then
    echo "$HEADER" >"$FILE"
  fi
}

add_invoice() {
  ensure_file
  echo "$1|$2|$3|OPEN|$4" >>"$FILE"
  echo "✅ Added invoice $2 for $3 on $1"
}

mark_paid() {
  ensure_file
  if grep -q "$1" "$FILE"; then
    sed -i '' "s/\(^[^|]*|$1|[^|]*|\)OPEN/\1PAID/" "$FILE"
    echo "✅ Marked $1 as PAID"
  else
    echo "❌ Invoice $1 not found"
  fi
}

list_open() {
  ensure_file
  echo "📋 Open invoices:"
  awk -F'|' '$4 == "OPEN" { print }' "$FILE"
}

sum_open() {
  ensure_file
  awk -F'|' 'NR > 1 && $4 == "OPEN" { sum += $3 } END { printf "💰 Total open: %.2f\n", sum }' "$FILE"
}

roll_invoice() {
  ensure_file
  from_id="$2"
  to_id="$3"

  # Mark source as ROLLED
  if grep -q "$from_id" "$FILE"; then
    sed -i '' "s/\(^[^|]*|$from_id|[^|]*|\)OPEN/\1ROLLED/" "$FILE"
    echo "🔁 Rolled $from_id into $to_id"
  else
    echo "❌ Invoice $from_id not found"
    return
  fi

  # Append note to destination if found
  if grep -q "$to_id" "$FILE"; then
    awk -F'|' -v from="$from_id" -v to="$to_id" -v OFS="|" '
      {
        if ($2 == to) {
          $5 = $5 ? $5 " | includes " from : "includes " from
        }
        print
      }
    ' "$FILE" >"$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    echo "📝 Noted $from_id in $to_id"
  else
    echo "⚠️  Invoice $to_id not found; only marked $from_id as ROLLED"
  fi
}

print_help() {
  cat <<EOF
📄 Usage: ./invoice.sh COMMAND [ARGS...]

Commands:
  add   YYYY-MM-DD INVOICE_ID AMOUNT [NOTE]   Add a new invoice as OPEN
  pay   INVOICE_ID                             Mark invoice as PAID
  roll  FROM_ID TO_ID                          Mark FROM_ID as ROLLED into TO_ID
  list                                         List all OPEN invoices
  sum                                          Show total amount of OPEN invoices

Examples:
  ./invoice.sh add 2025-05-06 INV-005 300.00 "Monthly subscription"
  ./invoice.sh pay INV-005
  ./invoice.sh roll INV-004 INV-006
  ./invoice.sh list
  ./invoice.sh sum
EOF
}

# Dispatcher
case "$1" in
add)
  add_invoice "$2" "$3" "$4" "$5"
  ;;
pay)
  mark_paid "$2"
  ;;
roll)
  roll_invoice "$1" "$2" "$3"
  ;;
list)
  list_open
  ;;
sum)
  sum_open
  ;;
help | --help | -h)
  print_help
  ;;
*)
  echo "❓ Unknown command: $1"
  print_help
  ;;
esac
