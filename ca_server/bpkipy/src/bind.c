#include "bpki_ext.h"

char bpki_func_docs[] = "Hello world description.";

PyMethodDef bpkipy_funcs[] = {
	{	"hello",
		(PyCFunction)hello,
		METH_NOARGS,
		bpki_func_docs},
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