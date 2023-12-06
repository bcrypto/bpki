#include "bpki_dvcs.h"

ASN1_SEQUENCE(DVCSRequestInformation) = {
    ASN1_SIMPLE(DVCSRequestInformation, version, ASN1_INTEGER),
    ASN1_SIMPLE(DVCSRequestInformation, service, ASN1_ENUMERATED),
} ASN1_SEQUENCE_END(DVCSRequestInformation);

IMPLEMENT_ASN1_FUNCTIONS(DVCSRequestInformation);
IMPLEMENT_ASN1_DUP_FUNCTION(DVCSRequestInformation);

ASN1_SEQUENCE(DVCSRequest) = {
    ASN1_SIMPLE(DVCSRequest, requestInformation, DVCSRequestInformation),
    ASN1_SIMPLE(DVCSRequest, data, ASN1_OCTET_STRING),
} ASN1_SEQUENCE_END(DVCSRequest);

IMPLEMENT_ASN1_FUNCTIONS(DVCSRequest);

ASN1_SEQUENCE(DVCSCertInfo) = {
    ASN1_SIMPLE(DVCSCertInfo, version, ASN1_INTEGER),
    ASN1_SIMPLE(DVCSCertInfo, service, ASN1_ENUMERATED),
    ASN1_SIMPLE(DVCSCertInfo, dvReqInfo, DVCSRequestInformation),
    ASN1_SIMPLE(DVCSCertInfo, messageImprint, X509_SIG),
    ASN1_SIMPLE(DVCSCertInfo, serialNumber, ASN1_INTEGER),
    ASN1_SIMPLE(DVCSCertInfo, genTime, ASN1_GENERALIZEDTIME),
    ASN1_OPT(DVCSCertInfo, dvStatus, PKIStatusInfo),
} ASN1_SEQUENCE_END(DVCSCertInfo);

IMPLEMENT_ASN1_FUNCTIONS(DVCSCertInfo);

ASN1_SEQUENCE(DigestInfo) = {
    ASN1_SIMPLE(DigestInfo, algor, X509_ALGOR),
    ASN1_SIMPLE(DigestInfo, digest, ASN1_OCTET_STRING)
} ASN1_SEQUENCE_END(DigestInfo)

IMPLEMENT_ASN1_FUNCTIONS(DigestInfo);

ASN1_SEQUENCE(DVCSErrorNotice) = {
    ASN1_SIMPLE(DVCSErrorNotice, status, PKIStatusInfo),
} ASN1_SEQUENCE_END(DVCSErrorNotice);

IMPLEMENT_ASN1_FUNCTIONS(DVCSErrorNotice);

PyObject *dvcs_extract_data(PyObject *self, PyObject *args) {
    const unsigned char* in = NULL;
    Py_ssize_t size;

    if (!PyArg_ParseTuple(args, "y#", &in, &size)) {
        return NULL;
    }

    DVCSRequest* req = d2i_DVCSRequest(NULL, &in, size);
    if (!req) {
        return NULL;
    }

    unsigned char* out = req->data->data;
    int len = req->data->length;
    PyObject *result = NULL;

    result = Py_BuildValue("y#", out, len);
    DVCSRequest_free(req);

    return result;
}

PyObject *dvcs_error_notice(PyObject *self, PyObject *args, PyObject *kwargs) {
    int status = -1;
    int failure_info = -1;
    PyObject* error_list = NULL;

    static char *kwlist[] = {"status", "error_list", "failure", NULL};

    if (!PyArg_ParseTupleAndKeywords(args, kwargs, "i|Oi", kwlist,
                                     &status, &error_list, &failure_info)) {
        return NULL;
    }

    DVCSErrorNotice* resp = DVCSErrorNotice_new();
    PKIStatusInfo_fill(resp->status, status, failure_info, error_list);

    unsigned char* out;
    unsigned char* buf;
    buf = out = (unsigned char*) malloc(10000);

    int len = i2d_DVCSErrorNotice(resp, &out);
    DVCSErrorNotice_free(resp);

    PyObject *result = NULL;

    result = Py_BuildValue("y#", buf, len);
    free(buf);

    return result;
}

int hash_message(const EVP_MD* md_type, const unsigned char *data, int len, unsigned char *digest) {
    EVP_MD_CTX *mdctx;
    unsigned int digest_len;

	if((mdctx = EVP_MD_CTX_new()) == NULL)
		return -1;

	if(1 != EVP_DigestInit_ex(mdctx, md_type, NULL))
		return -1;

	if(1 != EVP_DigestUpdate(mdctx, data, len))
		return -1;

	if(1 != EVP_DigestFinal_ex(mdctx, digest, &digest_len))
		return -1;

	EVP_MD_CTX_free(mdctx);
    return digest_len;
}

PyObject *dvcs_cert_info(PyObject *self, PyObject *args) {
    const unsigned char* in = NULL;
    Py_ssize_t size;
    long serial;

    if (!PyArg_ParseTuple(args, "y#i", &in, &size, &serial)) {
        PyErr_SetString(PyExc_ValueError, "Parameters are not parsed.");
        return NULL;
    }

    DVCSRequest* req = d2i_DVCSRequest(NULL, &in, size);
    if (!req) {
        PyErr_SetString(PyExc_ValueError, "PDVCSRequest is not decoded.");
        return NULL;
    }

    unsigned char* data = req->data->data;
    int len = req->data->length;
    int service = req->requestInformation->service;
    if(!service != 2){
        PyErr_SetString(PyExc_ValueError, "Service type is not supported.");
        return NULL;
    }

    const EVP_MD* md_type = EVP_get_digestbyname("belt-hash");

    if(!md_type){
        PyErr_SetString(PyExc_ValueError, "belt-hash is not found.");
        return NULL;
    }
    int digest_len = EVP_MD_size(md_type);
    unsigned char *digest;

	if((digest = (unsigned char *)OPENSSL_malloc(digest_len)) == NULL) {
	    PyErr_SetString(PyExc_ValueError, "Memory allocation problem.");
        return NULL;
	}

    int ret = hash_message(md_type, data, len, digest);
	if(ret != digest_len) {
	    PyErr_SetString(PyExc_ValueError, "Error in message hashing.");
		return NULL;
	}

    DVCSRequestInformation* reqInfo = DVCSRequestInformation_dup(req->requestInformation);

	DVCSRequest_free(req);

    DVCSCertInfo* ci = DVCSCertInfo_new();
    if(!ci) {
        PyErr_SetString(PyExc_ValueError, "Memory allocation for DVCSCertInfo problem.");
        return NULL;
    }
    ASN1_INTEGER_set(ci->version, 1);
    ASN1_ENUMERATED_set(ci->service, 2);
    ci->dvReqInfo = reqInfo;

    DigestInfo* sig = ci->messageImprint;
    X509_ALGOR_set_md(sig->algor, md_type);
    if (!ASN1_OCTET_STRING_set(sig->digest, digest, digest_len)) {
        return NULL;
    }
    ASN1_INTEGER_set(ci->serialNumber, 1);

    time_t now = time(NULL);
    struct tm* ptm = localtime(&now);
    char buffer[16];
    strftime(buffer, 32, "%Y%m%d%H%M%SZ", ptm);
    ASN1_GENERALIZEDTIME_set_string(ci->genTime, buffer);

    unsigned char* out;
    unsigned char* buf;
    buf = out = (unsigned char*) malloc(10000);

    len = i2d_DVCSCertInfo(ci, &out);

    PyObject *result = NULL;

    result = Py_BuildValue("y#", buf, len);
    DVCSCertInfo_free(ci);

    return result;
}

PyObject *dvcs_request(PyObject *self, PyObject *args) {
    const unsigned char* in = NULL;
    Py_ssize_t size;

    if (!PyArg_ParseTuple(args, "y#", &in, &size)) {
        PyErr_SetString(PyExc_ValueError, "Error in data reading.");
        return NULL;
    }

    DVCSRequest* req = DVCSRequest_new();
    if (!req) {
        PyErr_SetString(PyExc_ValueError, "Cannot create DVCS request.");
        return NULL;
    }
    if (!ASN1_ENUMERATED_set(req->requestInformation->service, 2)) {
        PyErr_SetString(PyExc_ValueError, "Cannot set service field to DVCS Request.");
        return 0;
    }
    if (!ASN1_INTEGER_set(req->requestInformation->version, 1)) {
        PyErr_SetString(PyExc_ValueError, "Cannot set service field to DVCS Request.");
        return 0;
    }
    if (!ASN1_OCTET_STRING_set(req->data, in, size)) {
        PyErr_SetString(PyExc_ValueError, "Cannot set data to DVCS Request.");
        return 0;
    }

    int len = 0;
    unsigned char* out;
    unsigned char* buf;
    buf = out = (unsigned char*) malloc(size + 1000);

    len = i2d_DVCSRequest(req, &out);
    DVCSRequest_free(req);

    PyObject *result = Py_BuildValue("y#", buf, len);

    return result;
}
