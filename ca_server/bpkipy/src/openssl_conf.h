#ifndef __OSSL_CONF_H__
#define __OSSL_CONF_H__

#define PY_SSIZE_T_CLEAN

#include <Python.h>

#include <openssl/crypto.h>
#include <openssl/conf.h>

PyObject *openssl_config(PyObject *self, PyObject *args);

#endif