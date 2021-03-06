[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.801834.svg)](https://doi.org/10.5281/zenodo.801834)

Zapdos
=====

Free (in all senses of the word) and open source software for modelling atmospheric plasmas using finite elements.
This application is built on top of the MOOSE framework, which can be found at [http://mooseframework.org](http://mooseframework.org)

The best documentation so far for this project is in Chapter 3 of the thesis located at
`doc/Lindsay_thesis_coupling_of_plasmas_and_liquids.pdf`. Some notes on
understanding existing chemistry kernels and/or implementing new ones in
Zapdos/MOOSE are given in `doc/Chemical_Reactions.ipynb`.

**Instructions for installing Zapdos:**

<ol>
  <li>Follow the <a href="https://mooseframework.inl.gov/getting_started/index.html">getting started instructions</a> for setting up the MOOSE environment. <b>Note that</b> Zapdos can be used with MOOSE installed in its own directory, or as a submodule within Zapdos. The latter option allows for a version of MOOSE that is guaranteed to work with the current version of Zapdos. If using MOOSE as a submodule is desired, proceed to Step 3, otherwise continue to Step 2.</li>
  <li><b>Using MOOSE in its own directory:</b> After installing the MOOSE environment execute the following commands in
  the directory above your MOOSE directory. E.g. if MOOSE is in
  <code>~/projects/moose</code>, then these commands should be executed from the
  <code>~/projects</code> directory
  <ul>
    <li><code>git clone https://github.com/shannon-lab/zapdos</code></li>
    <li><code>cd zapdos</code></li>
	  <li><code>git submodule init squirrel crane</code></li>
	  <li><code>git submodule update squirrel crane</code></li>
    <li><code>make -jn</code> where "n" is the number of logical processors on
  your computer</li>
  </ul>
  then continue to Step 4.</li>
  <li><b>Using MOOSE as a submodule:</b> After installing the MOOSE environment execute the following commands in
  the directory in which you are installing Zapdos (we recommend <code>~/projects/</code> to stay consistent with MOOSE conventions)
  <ul>
    <li><code>git clone https://github.com/shannon-lab/zapdos</code></li>
    <li><code>cd zapdos</code></li>
	  <li><code>git submodule init</code></li>
	  <li><code>git submodule update</code></li>
    <li><code>cd moose</code></li>
    <li><code>scripts/update_and_rebuild_libmesh.sh</code></li>
    <li><code>cd test</code></li>
    <li><code>make -jn</code> where "n" is the number of logical processors on your computer</li>
    <li><code>run_tests -jn</code></li>
    <li>If all tests pass, <code>cd ../../</code> to get back to the <code>zapdos</code> directory.</li>
    <li><code>make -jn</code></li>
  </ul>
  then continue to Step 4.</li>
  <li>To make sure the installation is working correctly, execute <code>./run_tests -jn</code>, substituting 'n' with your number of processors. All tests should pass with 'OK'
  <li>If everything checks out, you should now be able to run input files using the <code>zapdos-opt</code> executable in the <code>~/projects/zapdos</code> directory. Input files demonstrating the capabilities of zapdos can be found in the sub-directories of <code>~/projects/zapdos/tests</code>. If you want to start modifying an input file, a good one to choose is <code>mean_en.i</code> in <code>~/projects/zapdos/problems</code>. I typically run an input file like <code>mean_en.i</code> using the following command:</li>
  <ul>
    <li><code>cd ~/projects/zapdos/problems; ../zapdos-opt -i mean_en.i --color off 2>&1 | tee log.txt</code></li>
    <li>The above command will parse information of the iterative solution process to both the console and to the log file <code>log.txt</code></li>
    <li>The above command will also create an output file named <code>mean_en_out.e</code> containing all the solution variable values. These results are best viewed using a visualization tool like <b>Paraview</b>, downloadable <a href="http://www.paraview.org/download/">here</a></li>
    <li><b>Important note:</b> Many of the existing input files in the <code>problems</code> directory require <code>fileName.msh</code>. In order to create the requisite <code>.msh</code> file, you must run the command <code>gmsh -d fileName.geo</code> where <code>d</code> is the dimension of the mesh and <code>fileName.geo</code> is the source file for the mesh. <code>gmsh</code> can be installed on Ubuntu using <code>sudo apt-get install gmsh</code> or it can be downloaded <a href="http://gmsh.info/#Download">here</a>. Some of the <code>*.msh</code> files can also be found in the <code>tests</code> directory.</li>
  </ul>
  <li>In general the <code>problems</code> directory is meant to be the user work-space. S/he should feel welcome to modify any files in that directory. The <code>tests</code> directory, on the other hand, is meant to be a showcase and provide examples of the capabilities already established in zapdos. As zapdos is developed (by you hopefully!) and more capabilities are added, the tests directory will continue to grow. If you feel that you have added important new functionality, please create a test for it, such that any future changes will not break that capability.</li>
</ol>

Please do not hesitate to contact the zapdos google-group list if you have any questions about using or contributing to this software.

Email: <zapdos-users@googlegroups.com><br>
Google group: <https://groups.google.com/forum/#!forum/zapdos-users>
