#compdef invoice invoice.sh _invoice

_invoice() {
  local state
  local -a commands
  commands=(
    'add:Add a new invoice'
    'pay:Mark an invoice as paid'
    'roll:Mark an invoice as rolled into another'
    'list:List open invoices'
    'sum:Sum open invoices'
    'help:Show help message'
  )

  _arguments -C \
    '1:command:->command' \
    '*::arg:->args' && return 0

  case $state in
    command)
      _describe 'command' commands
      ;;
    args)
      local command="${words[1]}"
      echo ">>> inside args case with $command" > /tmp/invoice-debug.log

      case $command in
        pay|roll)
          local invoice_file
          invoice_file="$(pwd)/invoices.txt"

          if [[ ! -f "$invoice_file" ]]; then
            echo ">>> invoices.txt not found!" >> /tmp/invoice-debug.log
            return 1
          fi

          echo ">>> invoices.txt exists:" >> /tmp/invoice-debug.log
          cat "$invoice_file" >> /tmp/invoice-debug.log

          local ids
          ids=(${(f)"$(awk -F'|' '$4 == "OPEN" { print $2 }' "$invoice_file")"})
          echo ">>> Extracted IDs: ${ids[@]}" >> /tmp/invoice-debug.log

          if [[ ${#ids[@]} -gt 0 ]]; then
            compadd -- "${ids[@]}"
            echo ">>> Completion added: ${ids[@]}" >> /tmp/invoice-debug.log
          else
            echo ">>> No values to complete" >> /tmp/invoice-debug.log
          fi
          ;;
      esac
      ;;
  esac
}
