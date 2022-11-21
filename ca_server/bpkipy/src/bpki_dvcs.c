#include "bpki_dvcs.h"

ASN1_SEQUENCE(DVCSRequestInformation) = {
    ASN1_SIMPLE(DVCSRequestInformation, version, ASN1_INTEGER),
    ASN1_SIMPLE(DVCSRequestInformation, service, ASN1_ENUMERATED),
} ASN1_SEQUENCE_END(DVCSRequestInformation);

IMPLEMENT_ASN1_FUNCTIONS(DVCSRequestInformation);

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