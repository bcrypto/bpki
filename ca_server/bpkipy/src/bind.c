#include "bpki_ext.h"
#include "bpki_resp.h"

char bpki_func_docs[] = "Hello world description.";
char bpki_resp_docs[] = "BPKIResp object creation.";
char bpki_rev_docs[] = "BPKIRevokeReq object parsing.";

PyMethodDef bpkipy_funcs[] = {
	{	"hello", (PyCFunction)hello, METH_NOARGS, bpki_func_docs},
	{	"create_response", (PyCFunction)create_response, METH_VARARGS | METH_KEYWORDS, bpki_resp_docs},
	{	"parse_revoke", (PyCFunction)create_response, METH_VARARGS, bpki_rev_docs},
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