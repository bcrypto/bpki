#include "bpki_resp.h"

ASN1_SEQUENCE(PKIStatusInfo) = {
    ASN1_SIMPLE(PKIStatusInfo, status, ASN1_ENUMERATED),
    ASN1_SEQUENCE_OF_OPT(PKIStatusInfo, statusString, ASN1_UTF8STRING),
    ASN1_OPT(PKIStatusInfo, failInfo, ASN1_BIT_STRING),
} ASN1_SEQUENCE_END(PKIStatusInfo);

IMPLEMENT_ASN1_FUNCTIONS(PKIStatusInfo);

ASN1_SEQUENCE(BPKIResp) = {
    ASN1_SIMPLE(BPKIResp, statusInfo, PKIStatusInfo),
    ASN1_SIMPLE(BPKIResp, requestId, ASN1_OCTET_STRING),
    ASN1_OPT(BPKIResp, nonce, ASN1_OCTET_STRING),
} ASN1_SEQUENCE_END(BPKIResp);

IMPLEMENT_ASN1_FUNCTIONS(BPKIResp);


int PKIStatusInfo_set_status(PKIStatusInfo *si, int i) {
    return ASN1_INTEGER_set(si->status, i);
}

int PKIStatusInfo_push_status_string(PKIStatusInfo *si, const char *text) {
    ASN1_UTF8STRING *utf8_text = NULL;
    int ret = 0;

    if (text) {
        if ((utf8_text = ASN1_UTF8STRING_new()) == NULL
            || !ASN1_STRING_set(utf8_text, text, strlen(text)))
            goto err;
        if (si->statusString == NULL
            && (si->statusString = sk_ASN1_UTF8STRING_new_null()) == NULL)
            goto err;
        if (!sk_ASN1_UTF8STRING_push(si->statusString, utf8_text))
            goto err;
        utf8_text = NULL;       // Ownership is lost.
    }
    ret = 1;
 err:
    ASN1_UTF8STRING_free(utf8_text);
    return ret;
}

int PKIStatusInfo_set_failure_info(PKIStatusInfo *si, int failure) {
    if (si->failInfo == NULL
        && (si->failInfo = ASN1_BIT_STRING_new()) == NULL)
        goto err;
    if (!ASN1_BIT_STRING_set_bit(si->failInfo, failure, 1))
        goto err;
    return 1;
 err:
    return 0;
}

void PKIStatusInfo_fill(PKIStatusInfo* statusInfo, int status, int failure_info, PyObject* error_list) {
    PKIStatusInfo_set_status(statusInfo, status);

    int err_length = 0;
    char *err_string;
    PyObject *item;

    if(error_list != NULL)
        err_length = PyObject_Length(error_list);
    for (int index = 0; index < err_length; index++) {
        item = PyList_GetItem(error_list, index);
        err_string = PyUnicode_AsUTF8(item);
        PKIStatusInfo_push_status_string(statusInfo, err_string);
    }

    if(failure_info > 0)
        PKIStatusInfo_set_failure_info(statusInfo, failure_info);
}

int BPKIResp_set_request_id(BPKIResp *resp, unsigned char* req_id) {
    return ASN1_OCTET_STRING_set(resp->requestId, req_id, BPKI_REQ_ID_LENGTH);
}

int BPKIResp_set_nonce(BPKIResp *resp, unsigned char* nonce) {
    if(resp->nonce == NULL
        && (resp->nonce = ASN1_OCTET_STRING_new()) == NULL)
        return 1;
    return ASN1_OCTET_STRING_set(resp->nonce, nonce, BPKI_NONCE_LENGTH);
}

PyObject *create_response(PyObject *self, PyObject *args, PyObject *kwargs) {
    int status = -1;
    unsigned char *req_id = NULL;
    Py_ssize_t req_id_len = -1;
    unsigned char *nonce = NULL;
    Py_ssize_t nonce_len = -1;
    int failure_info = -1;
    PyObject* error_list = NULL;

    static char *kwlist[] = {"status", "req_id", "nonce", "error_list", "failure", NULL};

    if (!PyArg_ParseTupleAndKeywords(args, kwargs, "iy#|y#Oi", kwlist,
                                     &status, &req_id, &req_id_len, &nonce, &nonce_len,
                                     &error_list, &failure_info))
    {
        return NULL;
    }

    if(req_id_len != BPKI_REQ_ID_LENGTH) {
        PyErr_SetString(PyExc_ValueError, "Request ID length should be 32 bytes.");
        return NULL;
    }
    if( (nonce != NULL) && (nonce_len != BPKI_NONCE_LENGTH)) {
        PyErr_SetString(PyExc_ValueError, "Nonce length should be 8 bytes.");
        return NULL;
    }

    BPKIResp* resp = BPKIResp_new();

    PKIStatusInfo_fill(resp->statusInfo, status, failure_info, error_list);
    BPKIResp_set_request_id(resp, req_id);
    if(nonce != NULL)
        BPKIResp_set_nonce(resp, nonce);

    unsigned char* out;
    unsigned char* buf;
    buf = out = (unsigned char*) malloc(10000);

    int len = i2d_BPKIResp(resp, &out);
    BPKIResp_free(resp);

    PyObject *result = NULL;

    result = Py_BuildValue("y#", buf, len);
    free(buf);

    return result;
}
