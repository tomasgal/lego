seq 0 999999 | \
while read n; do
    url="https://server/$n.pdf"
    echo -n "Checking $n.pdf ... "
    status=$(wget --server-response --spider "$url" 2>&1 | awk '/HTTP\// {print $2}' | tail -1)
    echo "$status"

    if [ "$status" = "200" ]; then
        wget -q "$url"
        echo "Downloaded $n.pdf"
    fi

    sleep 5
done