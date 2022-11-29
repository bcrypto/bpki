#include "bpki_ext.h"

ASN1_SEQUENCE(BPKIRevokeReq) = {
    ASN1_SIMPLE(BPKIRevokeReq, issuer, X509_NAME),
    ASN1_SIMPLE(BPKIRevokeReq, serialNumber, ASN1_INTEGER),
    ASN1_SIMPLE(BPKIRevokeReq, revokePwd, ASN1_UTF8STRING),
    ASN1_SIMPLE(BPKIRevokeReq, reasonCode, ASN1_ENUMERATED),
    ASN1_OPT(BPKIRevokeReq, invalidityDate, ASN1_GENERALIZEDTIME),
    ASN1_OPT(BPKIRevokeReq, comment, ASN1_UTF8STRING),
} ASN1_SEQUENCE_END(BPKIRevokeReq);

IMPLEMENT_ASN1_FUNCTIONS(BPKIRevokeReq);

char* BPKIRevokeReq_get_serial(BPKIRevokeReq *req) {
    return i2s_ASN1_INTEGER(NULL, req->serialNumber);
}

long BPKIRevokeReq_get_reason(BPKIRevokeReq *req) {
    return ASN1_ENUMERATED_get(req->reasonCode);
}

char* get_asn1_utf_string(ASN1_UTF8STRING* str) {
    if(str == NULL)
        return NULL;
    unsigned char* out = NULL;
    ASN1_STRING_to_UTF8(&out, str);
    return (char*) out;
}

char* BPKIRevokeReq_get_revoke_pwd(BPKIRevokeReq *req) {
    return get_asn1_utf_string(req->revokePwd);
}

char* BPKIRevokeReq_get_comment(BPKIRevokeReq *req) {
    return get_asn1_utf_string(req->comment);
}

char* BPKIRevokeReq_get_invalidity_date(BPKIRevokeReq *req) {
    return get_asn1_utf_string((ASN1_UTF8STRING*) req->invalidityDate);
}

char* BPKIRevokeReq_get_issuer(BPKIRevokeReq *req) {
    return X509_NAME_oneline(req->issuer, NULL, -1);
}

PyObject *parse_revoke(PyObject *self, PyObject *args) {
    const unsigned char* in = NULL;
    Py_ssize_t len;

    if (!PyArg_ParseTuple(args, "y#", &in, &len)) {
        return NULL;
    }
    BPKIRevokeReq* req = d2i_BPKIRevokeReq(NULL, &in, len);

    char* serial = BPKIRevokeReq_get_serial(req);
    char* pwd = BPKIRevokeReq_get_revoke_pwd(req);
    char* name = BPKIRevokeReq_get_issuer(req);
    long reason = BPKIRevokeReq_get_reason(req);

    PyObject* result = Py_BuildValue(
        "{s:s,s:s,s:s,s:i}", "serial", serial, "password", pwd,
        "issuer", name, "reason", reason
    );
    char* time = BPKIRevokeReq_get_invalidity_date(req);
    char* comment = BPKIRevokeReq_get_comment(req);
    if(time != NULL) {
        PyObject* pytime = PyUnicode_DecodeUTF8(time, strlen(time), NULL);
        PyDict_SetItemString(result, "date", pytime);
    }
    if(comment != NULL) {
        PyObject* pycomment = PyUnicode_DecodeUTF8(comment, strlen(comment), NULL);
        PyDict_SetItemString(result, "comment", pycomment);
    }

    OPENSSL_free(name);
    OPENSSL_free(serial);
    OPENSSL_free(pwd);
    OPENSSL_free(time);
    OPENSSL_free(comment);
    BPKIRevokeReq_free(req);
    return result;
}

X509 *load_cert(const char *file)
{
    X509 *x = NULL;
    BIO *cert = BIO_new_file(file, "rb");

    if (cert != NULL)
        d2i_X509_bio(cert, &x);
    BIO_free(cert);
    return x;
}

PyObject *create_revoke(PyObject *self, PyObject *args, PyObject *kwargs) {
    const char* recipfile = NULL;
    const char* pwd = NULL;
    int reason = 3;
    const char* invalidityDate = NULL;
    const char* comment = NULL;
    int format = MBSTRING_UTF8;

    static char *kwlist[] = {"cert_file", "password", "reason", "invalidity_date", "comment", NULL};

    if (!PyArg_ParseTupleAndKeywords(args, kwargs, "ssi|ss", kwlist,
                                     &recipfile, &pwd, &reason, &invalidityDate, &comment))
    {
        PyErr_SetString(PyExc_ValueError, "Error in parameters reading.");
        return NULL;
    }

    X509* cert = load_cert(recipfile);
    if (cert == NULL) {
        PyErr_SetString(PyExc_ValueError, "Certificate is not loaded.");
        return NULL;
    }

    BPKIRevokeReq* req = BPKIRevokeReq_new();
    if(!ASN1_STRING_set(req->revokePwd, pwd, strlen(pwd))) {
        PyErr_SetString(PyExc_ValueError, "Cannot set revokePwd field.");
        return NULL;
    }
    if(!ASN1_ENUMERATED_set(req->reasonCode, reason)) {
        PyErr_SetString(PyExc_ValueError, "Cannot set reasonCode field.");
        return NULL;
    }
    if (invalidityDate) {
        req->invalidityDate = ASN1_GENERALIZEDTIME_new();
        if(!ASN1_GENERALIZEDTIME_set_string(req->invalidityDate, invalidityDate)) {
            PyErr_SetString(PyExc_ValueError, "Cannot set invalidityDate field.");
            return NULL;
        }
    }
    if (comment) {
        req->comment = ASN1_STRING_type_new(format);
        if(!ASN1_STRING_set(req->comment, comment, strlen(comment))) {
            PyErr_SetString(PyExc_ValueError, "Cannot set comment field.");
            return NULL;
        }
    }

    X509_NAME* tmp_name = req->issuer;
    req->issuer = X509_get_issuer_name(cert);
    ASN1_INTEGER* tmp_serial = req->serialNumber;
    req->serialNumber = X509_get_serialNumber(cert);

    unsigned char* out;
    unsigned char* buf;
    buf = out = (unsigned char*) malloc(10000);

    int len = i2d_BPKIRevokeReq(req, &out);

    req->issuer = tmp_name;
    req->serialNumber = tmp_serial;
    BPKIRevokeReq_free(req);
    X509_free(cert);

    PyObject *result = NULL;

    result = Py_BuildValue("y#", buf, len);
    free(buf);

    return result;
}
