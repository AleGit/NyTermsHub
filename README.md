# NyTermsHub

A first order theorem prover with equality.

To build and run the this application, 
the command line tool, or the unit tests 
the following data and libraries have to be installed.

- flex
- yacc
- tptp problem files
- yices 2 (c api, used)
- z3 (c api, unused, optimization, unsatisfiable core)
- cvc4 (c++ api, unused)

##Flex and Yacc 
====
… are preinstalled on Macs. See also `Docs/yacc` in this project for configuration details.

The yacc compiler flag `-p tptp_` for yacc source files (*.ym, *.y) changes the function prefix from `yy_` to `tptp_`. 
The yacc build option `input file stem` uses the yacc source file names for the generated parser source files.


##TPTP problem files
====
Download the current release of the TPTP 
(*Thousands of Problems for Theorem Provers*) Library from [www.cs.miami.edu/~tptp/](http://www.cs.miami.edu/~tptp/) 
that contains problems, axiom sets, documents, and utilities. 
Unpack the archive, 
move the resulting directory to any place you like, 
and create a symbolic link `TPTP` to the directory in `/Users/Shared/`.
(Or you edit the xcode scheme to set -tptp_root or TPTP_ROOT 
to the path where directories 'Axioms' and 'Problems' are residing)

    cd /Users/Shared/
    tar -xzf ~/Downloads/TPTP-v6.3.0.tgz 
    tar -xz ~/Downloads/TPTP-v6.3.0.tar
    ln -s TPTP-v6.3.0 TPTP

The tptp root path default is `/Users/Shared/TPTP`.

For `TptpPathTests` to succeed copy these files:


    cp /Users/Shared/TPTP/Problems/SYN/SYN000-2.p /Users/Shared/SampleA.p
    cp /Users/Shared/TPTP/Axioms/SYN000-0.ax /Users/Shared/AxiomB.ax
    mkdir /Users/Shared/Axioms
    cp /Users/Shared/TPTP/Axioms/SYN000-0.ax /Users/Shared/Axioms/AxiomsC.ax

## Yices2, Z3, CVC4 (SMT Provers)
=====
Download and install yices 2 for Mac OS X (64 bits) from [yices.csl.sri.com](http://yices.csl.sri.com). This project uses the precompiled binary.
Follow the instructions from the website. Check for the following files on your system:

    /usr/local/include/yices.h
    /usr/local/lib/libz3.dylib

Download, build and install z3 (by Microsoft) from [Github](https://github.com/Z3Prover/z3). This project uses the build from source version.
Follow the instructions from the website. Check for the following files on your system:

    /usr/local/include/z3.h
    /usr/local/lib/libyices.dylib

After installing [MacPorts](https://www.macports.org), [cvc4](http://cvc4.cs.nyu.edu/web/) can be easily installed with

    sudo port install cvc4
    /opt/local/include/cvc4/cvc4.h 
    /opt/local/lib/libcvc4.dylib

Since cvc4 provides a C++ API it can not be used directly and a C or Obj-C wrapper has to be provided (not done yet).

### project linker flags

    -lyices -lz3 -L/usr/local/lib -lcvc4 -L/opt/local/lib

See also `Docs/Yices`, `Docs/z3`, and `Docs/cvc4` in this project for configuration details.




