#include "openssl_conf.h"

PyObject *openssl_config(PyObject *self, PyObject *args) {
    const char* filename = NULL;
    Py_ssize_t len;

    if (!PyArg_ParseTuple(args, "s", &filename)) {
        return NULL;
    }
    OPENSSL_init_crypto(
        OPENSSL_INIT_ADD_ALL_CIPHERS |
        OPENSSL_INIT_ADD_ALL_DIGESTS |
        OPENSSL_INIT_LOAD_CRYPTO_STRINGS |
        OPENSSL_INIT_LOAD_CONFIG,
        NULL
    );
    CONF_modules_load_file(
        filename,
        "openssl_conf",
        CONF_MFLAGS_DEFAULT_SECTION
    );
    Py_RETURN_NONE;
}