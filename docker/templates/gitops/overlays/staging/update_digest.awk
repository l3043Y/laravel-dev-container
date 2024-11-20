#!/usr/bin/awk -f

BEGIN {
    # Get the new digest value from the environment variable
    REGISTRY_IMAGE_URL = ENVIRON["REGISTRY_IMAGE_URL"]
    NEW_DIGEST = ENVIRON["IMAGE_LATEST_DIGEST"]
    NEW_TAG = ENVIRON["IMAGE_RELEASE_TAG"]
}

/name: apps-image-latest/ {
    flag = 1
    line_number = NR
}
flag && /newName:/ {
    sub(/:.*/, ": " REGISTRY_IMAGE_URL)
    flag = 2
}

flag && /newTag:/ {
    sub(/:.*/, ": " NEW_TAG)
    flag = 3
}

flag && /digest:/ {
    sub(/:.*/, ": " NEW_DIGEST)
    flag = 0
}

# Print every line
1

END {
    if (flag) {
        print "Error: digest not found for apps-image-latest", line_number > "/dev/stderr"
        exit 1
    }
}