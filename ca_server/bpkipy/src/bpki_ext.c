#include "bpki_ext.h"

PyObject * hello(PyObject * self) {
	return PyUnicode_FromFormat("Hello C extension!");
}

ASN1_SEQUENCE(BPKIRevokeReq) = {
    ASN1_SIMPLE(BPKIRevokeReq, issuer, X509_NAME),
    ASN1_SIMPLE(BPKIRevokeReq, serialNumber, ASN1_INTEGER),
    ASN1_SIMPLE(BPKIRevokeReq, revokePwd, ASN1_UTF8STRING),
    ASN1_SIMPLE(BPKIRevokeReq, reasonCode, ASN1_ENUMERATED),
    ASN1_OPT(BPKIRevokeReq, invalidityDate, ASN1_GENERALIZEDTIME),
    ASN1_OPT(BPKIRevokeReq, comment, ASN1_UTF8STRING),
} ASN1_SEQUENCE_END(BPKIRevokeReq);

IMPLEMENT_ASN1_FUNCTIONS(BPKIRevokeReq);

char* BPKIRevokeReq_get_serial(BPKIRevokeReq *req)
{
    return i2s_ASN1_INTEGER(NULL, req->serialNumber);
}

long BPKIRevokeReq_get_reason(BPKIRevokeReq *req)
{
    return ASN1_ENUMERATED_get(req->reasonCode);
}

char* BPKIRevokeReq_get_revoke_pwd(BPKIRevokeReq *req)
{
    ASN1_UTF8STRING* oct = req->revokePwd;
    unsigned char* out = NULL;
    ASN1_STRING_to_UTF8(&out, oct);
    return (char*) out;
}

char* BPKIRevokeReq_get_issuer(BPKIRevokeReq *req)
{
    return X509_NAME_oneline(req->issuer, NULL, -1);
}
