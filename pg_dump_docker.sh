
#!/bin/bash

docker run --rm --network=host -v "$PWD:/backup" postgres:15 \

  pg_dump "$@"

