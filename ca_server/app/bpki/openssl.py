# *****************************************************************************
# \file openssl.py
# \project bee2evp [EVP-interfaces over bee2 / engine of OpenSSL]
# \brief A python wrapper over openssl commmands
# \created 2019.07.10
# \version 2021.02.18
# \license This program is released under the GNU General Public License 
# version 3 with the additional exemption that compiling, linking, 
# and/or using OpenSSL is allowed. See Copyright Notices in bee2evp/info.h.
# *****************************************************************************

import subprocess
import os

from flask import current_app

# os.environ['OPENSSL_CONF'] = os.getcwd() + '/openssl.cfg'
OPENSSL_EXE_PATH = 'openssl'


def openssl(cmd, prefix='', echo=False, type_=0):
    cmd = "{} {} {}".format(prefix, OPENSSL_EXE_PATH, cmd)
    env1 = os.environ.copy()
    env1['OPENSSL_CONF'] = os.getcwd() + '/app_openssl.cfg'
    if echo:
        print(cmd)
    current_app.logger.debug(cmd)

    if type_ == 0:
        p = subprocess.Popen(cmd,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE,
                             stdin=subprocess.PIPE,
                             executable='/bin/bash',
                             env=env1,
                             shell=True
                             )

        out, err_out = p.communicate()
        retcode = p.poll()
        current_app.logger.debug(out)
        current_app.logger.debug(err_out)
        return retcode ^ 1, out, err_out

    if type_ == 1:
        p = subprocess.Popen(cmd,
                             shell=True,
                             preexec_fn=os.setsid)
        return p

    if type_ == 2:
        out = subprocess.check_output(cmd,
                                      shell=True)
        return out
