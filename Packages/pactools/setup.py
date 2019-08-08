import setuptools  # noqa  # used with `python setup.py develop`
from distutils.core import setup

descr = """Estimation of phase-amplitude coupling (PAC) in neural time series,
           including with driven auto-regressive (DAR) models."""

setup(
    name='pactools',
    version='0.1',
    description=descr,
    long_description=open('README.rst').read(),
    license='BSD (3-clause)',
    packages=[
        'pactools',
        'pactools.dar_model',
        'pactools.utils',
    ], )
