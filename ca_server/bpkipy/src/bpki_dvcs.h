#ifndef __BPKI_DVCS_H__
#define __BPKI_DVCS_H__

#define PY_SSIZE_T_CLEAN

#include <Python.h>
#include <time.h>
#include <openssl/asn1t.h>
#include <openssl/x509.h>
#include <openssl/evp.h>
#include "bpki_resp.h"

/*  DVCSRequest ::= SEQUENCE  {
      requestInformation         DVCSRequestInformation,
      data                       Data,
	}

    DVCSRequestInformation ::= SEQUENCE  {
      version                      INTEGER DEFAULT 1,
      service                      ServiceType,
	}

	ServiceType ::= ENUMERATED {vsd(2)}

    Data ::= CHOICE {
      message          OCTET STRING,
	}
*/

typedef struct _DVCSRequestInformation {
    ASN1_INTEGER* version;
    ASN1_ENUMERATED* service;
} DVCSRequestInformation;

typedef struct _DVCSRequest {
    DVCSRequestInformation* requestInformation;
    ASN1_OCTET_STRING* data;
} DVCSRequest;

/*  DVCSResponse ::= CHOICE {
      dvCertInfo         DVCSCertInfo,
      dvErrorNote        [0] DVCSErrorNotice
    }

DVCSCertInfo::= SEQUENCE  {
      version             INTEGER DEFAULT 1,
      dvReqInfo           DVCSRequestInformation,
      messageImprint      DigestInfo,
      serialNumber        INTEGER,
      genTime             GeneralizedTime,
      dvStatus            [0] PKIStatusInfo OPTIONAL,
	}

    DigestInfo ::= SEQUENCE {
      digestAlgorithm  DigestAlgorithmIdentifier,
      digest           Digest }
    Digest ::= OCTET STRING

    DVCSErrorNotice ::= SEQUENCE {
      transactionStatus        PKIStatusInfo,
    }
*/

typedef struct _DigestInfo {
    X509_ALGOR *algor;
    ASN1_OCTET_STRING *digest;
} DigestInfo;

typedef struct _DVCSCertInfo{
    ASN1_INTEGER* version;
    DVCSRequestInformation*  dvReqInfo;
    DigestInfo*  messageImprint;
    ASN1_INTEGER* serialNumber;
    ASN1_GENERALIZEDTIME*  genTime;
    PKIStatusInfo*  dvStatus;
} DVCSCertInfo;

typedef struct _DVCSErrorNotice {
    PKIStatusInfo* status;
} DVCSErrorNotice;

PyObject *dvcs_extract_data(PyObject *self, PyObject *args);
PyObject *dvcs_error_notice(PyObject *self, PyObject *args, PyObject *kwargs);
PyObject *dvcs_cert_info(PyObject *self, PyObject *args);
PyObject *dvcs_request(PyObject *self, PyObject *args);

#endif
