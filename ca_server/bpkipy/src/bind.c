#include "bpki_ext.h"
#include "bpki_resp.h"
#include "bpki_dvcs.h"

char bpki_resp_docs[] = "BPKIResp object creation.";
char bpki_rev_docs[] = "BPKIRevokeReq object parsing.";
char dvcs_data_docs[] = "Data extraction from DVCSRequest object.";

PyMethodDef bpkipy_funcs[] = {
	{	"create_response", (PyCFunction)create_response, METH_VARARGS | METH_KEYWORDS, bpki_resp_docs},
	{	"parse_revoke", (PyCFunction)parse_revoke, METH_VARARGS, bpki_rev_docs},
	{	"dvcs_extract_data", (PyCFunction)dvcs_extract_data, METH_VARARGS, dvcs_data_docs},
	{	NULL}
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
