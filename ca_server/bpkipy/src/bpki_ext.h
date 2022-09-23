#ifndef __BPKI_EXT_H__
#define __BPKI_EXT_H__

#include <Python.h>
#include <openssl/asn1t.h>
#include <openssl/x509.h>

/*
BPKIRevokeReq ::= SEQUENCE {
  issuer          Name,
  serialNumber    INTEGER,
  revokePwd       UTF8String,
  reasonCode      CRLReason,
  invalidityDate  GeneralizedTime OPTIONAL,
  comment         UTF8String OPTIONAL }

*/

typedef struct _BPKIRevokeReq {
    X509_NAME* issuer;
    ASN1_INTEGER* serialNumber;
    ASN1_UTF8STRING* revokePwd;
    ASN1_ENUMERATED* reasonCode;
    ASN1_GENERALIZEDTIME* invalidityDate;
    ASN1_UTF8STRING* comment;
} BPKIRevokeReq;

PyObject * hello(PyObject *);


#endif