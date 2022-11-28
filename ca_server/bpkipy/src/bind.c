#include "bpki_ext.h"
#include "bpki_resp.h"
#include "bpki_dvcs.h"
#include "openssl_conf.h"

char bpki_resp_docs[] = "BPKIResp object creation.";
char bpki_rev_docs[] = "BPKIRevokeReq object parsing.";
char dvcs_req_docs[] = "DVCSRequest object creation.";
char dvcs_data_docs[] = "Data extraction from DVCSRequest object.";
char dvcs_err_docs[] = "DVCSErrorNotice object creation.";
char dvcs_resp_docs[] = "DVCSCertInfo object creation.";
char ossl_conf_docs[] = "OpenSSL config loading.";

PyMethodDef bpkipy_funcs[] = {
	{	"create_response", (PyCFunction)create_response, METH_VARARGS | METH_KEYWORDS, bpki_resp_docs},
	{	"parse_revoke", (PyCFunction)parse_revoke, METH_VARARGS, bpki_rev_docs},
	{	"dvcs_extract_data", (PyCFunction)dvcs_extract_data, METH_VARARGS, dvcs_data_docs},
	{	"dvcs_error_notice", (PyCFunction)dvcs_error_notice, METH_VARARGS | METH_KEYWORDS, dvcs_err_docs},
	{	"dvcs_cert_info", (PyCFunction)dvcs_cert_info, METH_VARARGS, dvcs_resp_docs},
	{	"dvcs_request", (PyCFunction)dvcs_request, METH_VARARGS, dvcs_req_docs},
	{	"openssl_config", (PyCFunction)openssl_config, METH_VARARGS, ossl_conf_docs},
	{	NULL }
};

char bpkipy_docs[] = "Extensions for BPKI formats.";

PyModuleDef bpkipy_mod = {
	PyModuleDef_HEAD_INIT,
	"bpkipy",
	bpkipy_docs,
	-1,
	bpkipy_funcs,
	NULL,
	NULL,
	NULL,
	NULL
};

PyMODINIT_FUNC PyInit_bpkipy(void) {
	return PyModule_Create(&bpkipy_mod);
}
