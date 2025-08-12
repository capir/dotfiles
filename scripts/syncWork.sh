#!/bin/zsh

# .env example
# SW_SERVER=tapi
# SW_USER=travelapi
# SW_PATH1=/home/travelapi/prod
# SW_PATH2=/home/travelapi/staging


# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo ".env file not found. Exiting."
  exit 1
fi

# Collect all PATH variables dynamically
PATHS=()
for var in ${(k)parameters}; do
  if [[ $var == SW_PATH* ]]; then
    PATHS+=("${(P)var}")
  fi
done

# Prompt user to choose path
echo "Where? :"
index=1
for path in "${PATHS[@]}"; do
  echo "$index) ${path%%:*}"
  index=$((index + 1))
done
read -k1 choice
echo

# Determine the path based on the choice
if [ "$choice" -ge 1 ] && [ "$choice" -le "${#PATHS[@]}" ]; then
  FULL_PATH="${PATHS[$((choice))]}"
  REMOTE_DIR="${FULL_PATH%%:*}"  # Extract the directory name (before the colon)
  REMOTE_PATH="${FULL_PATH#*:}/ch.tar"  # Extract the full path including the filename (after the colon)
else
  echo "Invalid choice. Exiting."
  exit 1
fi

# Prompt user to choose direction
echo "Direction? :"
echo "1) Upload to server"
echo "2) Download from server"
read -k1 direction
echo

case $direction in
    1)
        # Upload to server

        echo 'Creating tar...'
        /usr/local/bin/git add .
        /usr/local/bin/git diff --cached --name-only > l.txt
        /usr/bin/tar -T l.txt -cf ch.tar

        echo 'Pushing tar...'
        /usr/bin/scp ch.tar $SW_SERVER:$REMOTE_PATH

        # Execute commands on the destination server
        /usr/bin/ssh $SW_SERVER << ENDSSH
        sudo su $SW_USER
        cd "$REMOTE_DIR"
        tar xf ch.tar
        rm ch.tar
ENDSSH

        /bin/rm l.txt ch.tar
        echo "Upload complete to $REMOTE_DIR."
        ;;
    2)
        # Download from server
        echo 'Creating tar...'
        /usr/bin/ssh $SW_SERVER << ENDSSH
        sudo su $SW_USER
        cd "$REMOTE_DIR"
        git add .
        git diff --cached --name-only > l.txt
        tar -T l.txt -cf ch.tar
        rm l.txt
ENDSSH

        echo 'Fetching tar...'
        /usr/bin/scp $SW_SERVER:$REMOTE_PATH ./ch.tar
        /usr/bin/tar xf ./ch.tar

        echo 'Cleaning up...'
        /usr/bin/ssh $SW_SERVER "rm $REMOTE_PATH"
        /bin/rm ./ch.tar
        echo "Download and extraction complete from $REMOTE_DIR."
        ;;
    *)
        echo "Invalid direction choice. Exiting."
        exit 1
        ;;
esac

