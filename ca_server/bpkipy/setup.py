try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension

module1 = Extension(
    'bpkipy',
    include_dirs=['/usr/local/include'],
    libraries=['crypto'],
    library_dirs=['/usr/local/lib'],
    sources=[
        'src/bpki_ext.c', 'src/bpki_resp.c', 'src/bpki_dvcs.c', 'src/bind.c',
        'src/openssl_conf.c'
    ],
)


setup(
    name="bpkipy",
    version="0.2.11",
    author="Mikhail Mitskevich",
    author_email="mitskevichmn@gmail.com",
    description="Extensions for BPKI formats",
    classifiers=[
        "Programming Language :: C",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    ext_modules=[module1]
)
