#!/bin/bash

#RUN_IP="$1"
#RUN_PORT="$2"
#RUN_IP="127.0.0.1"
RUN_IP="0.0.0.0"
RUN_PORT="48080"

BASEDIR="/var/bertain-cdn/nasapuff/flask"
BINDIR="${BASEDIR}/venv-nasapuff/bin"
PYTHON="${BINDIR}/python3"
ACTIVATOR="${BINDIR}/activate"
TEMPLATE_DIR="${BASEDIR}/templates"

FLASK="${BINDIR}/flask"

PY_TIME_ENV="prod"
PY_TIME_APP="nasapuff_flask.py"

cd ${BASEDIR}

export FLASK_ENV=${PY_TIME_ENV}
export FLASK_APP=${PY_TIME_APP}

#SOURCE="source ${ACTIVATOR}"
source ${ACTIVATOR}

${FLASK} run --host ${RUN_IP} --port ${RUN_PORT}

