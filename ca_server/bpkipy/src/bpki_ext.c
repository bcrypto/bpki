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

    if (!PyArg_ParseTuple(args, "y#", &in, &len))
    {
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
