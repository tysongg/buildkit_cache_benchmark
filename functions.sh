function build {
    BUILDER=$1
    DOCKER_FILE=$2
    DOCKER_CONTEXT=$3
    DOCKER_BASETAG=$4
    CACHED=$5

    CACHE_STR="--no-cache"
    CACHE_FROM=""
    if [ "$CACHED" = True ]; then
        CACHE_STR=""
        CACHE_FROM="--cache-from=${DOCKER_BASETAG}:buildkit"

        if [ "$BUILDER" == "docker" ]; then
            docker pull ${DOCKER_BASETAG}:docker
        fi
    fi

    if [ "$BUILDER" == "buildkit" ]; then
        CMD="docker build $CACHE_STR \
        $CACHE_FROM \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        -t ${DOCKER_BASETAG}:buildkit \
        -f $DOCKER_FILE \
        $DOCKER_CONTEXT"

        echo "RUNNING: $CMD"
        DOCKER_BUILDKIT=1 $CMD
    fi

    if [ "$BUILDER" == "docker" ]; then
        CMD="docker build $CACHE_STR \
        -t ${DOCKER_BASETAG}:docker \
        -f $DOCKER_FILE \
        $DOCKER_CONTEXT"

        echo "RUNNING: $CMD"
        $CMD
    fi
}

function cleanLocal {
    docker image remove python:3.8.5-buster || true
    docker image remove localhost:5000/python:3.8.5-buster || true
    docker image remove ${DOCKER_BASETAG}:buildkit || true
}