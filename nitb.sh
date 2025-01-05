#!/bin/bash
exec osmo-nitb -c /opt/GSM/openbsc.cfg -l /opt/GSM/hlr.sqlite3 -P -M /tmp/bsc_mncc -C --debug=DRLL:DCC:DMM:DRR:DRSL:DNM --yes-i-really-want-to-run-prehistoric-software
