NyTermsCL (command line) and NyTerms read arguments and environments

(precedence: argument > environment > default value)

argument   | environment | default value       | description 
---------- | ----------- | ------------------- | ---
-tptp_root | TPTP_ROOT   | /Users/Shared/TPTP  | root path to 
           |             | /Users/Shared/TPTP/Problems | … problems
           |             | /Users/Shared/TPTP/Axioms | … axioms
-problem   |             |                     | name of a problem, e.g. HWV134-1
-file      |             |                     | absolute path to a problem file
-order     |             | kbo                 | kbo, lpo
-precedence|             | lexicographic
-w0        |             | 0


--tptp_root=/Users/Shared/TPTP

--problem=HWV134-1

--file=/Users/Shared/TPTP/Problems/HWV/HWV134-1.p

--order=kbo

--precendence=lexicographic