#ifndef __BPKI_RESP_H__
#define __BPKI_RESP_H__

#define PY_SSIZE_T_CLEAN

#include <Python.h>
#include <openssl/asn1t.h>
#include <openssl/ts.h>

/*
BPKIResp ::= SEQUENCE {
    statusInfo PKIStatusInfo,
    requestId OCTET STRING(SIZE(32)),
    nonce OCTET STRING(SIZE(8)) OPTIONAL }
PKIStatusInfo ::= SEQUENCE {
    status PKIStatus,
    statusString PKIFreeText OPTIONAL,
    failInfo PKIFailureInfo OPTIONAL }
PKIFreeText ::= SEQUENCE SIZE(1..MAX) OF UTF8String
PKIStatus ::= INTEGER {
    granted (0),
    grantedWithMods (1),
    rejection (2),
    waiting (3),
    revocationWarning (4),
    revocationNotification (5) }
PKIFailureInfo ::= BIT STRING {
    badAlg (0),
    badRequest (2),
    badTime (3),
    badDataFormat (5),
    timeNotAvailable (14),
    unacceptedPolicy (15),
    unacceptedExtension (16),
    addInfoNotAvailable (17),
    systemFailure (25) }
*/

#define BPKI_REQ_ID_LENGTH 32
#define BPKI_NONCE_LENGTH 8

typedef struct _PKIStatusInfo {
    ASN1_ENUMERATED* status;
    STACK_OF(ASN1_UTF8STRING)* statusString;
    ASN1_BIT_STRING* failInfo;
} PKIStatusInfo;

DECLARE_ASN1_FUNCTIONS(PKIStatusInfo);

typedef struct _BPKIResp {
    PKIStatusInfo* statusInfo;
    ASN1_OCTET_STRING* requestId;
    ASN1_OCTET_STRING* nonce;
} BPKIResp;

int PKIStatusInfo_set_status(PKIStatusInfo *si, int i);
int PKIStatusInfo_push_status_string(PKIStatusInfo *si, const char *text);
int PKIStatusInfo_set_failure_info(PKIStatusInfo *si, int failure);
void PKIStatusInfo_fill(PKIStatusInfo* statusInfo, int status, int failure_info, PyObject* error_list);

PyObject *create_response(PyObject *self, PyObject *args, PyObject *kwargs);

#endif