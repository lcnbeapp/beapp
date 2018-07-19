# The Batch Electroencephalography Automated Processing Platform (BEAPP)
<p>The Boston EEG Automated Processing Pipeline (BEAPP) is a modular, Matlab-based software designed to facilitate automated, flexible batch processing of baseline and event-related EEG files in datasets with mixed acquisition formats.</p>
<p>Rather than prescribing a specified set of EEG processing steps, BEAPP allows users to choose from a menu of options. Each option can be turned on or off, and options turned &ldquo;on&rdquo; can be tailored to fit the user&rsquo;s needs.&nbsp; BEAPP currently provides options for the following user-controlled modules:</p>
<ol>
<li><a href="http://journal.frontiersin.org/article/10.3389/fninf.2015.00016/full">PREP Pipeline</a></li>
<ol>
<li>Line noise removal, interpolation of bad channels, robust average referencing</li>
</ol>
<li>Filtering</li>
<ol>
<li>High-pass</li>
<li>Low-pass</li>
<li>Notch</li>
<li><a href="http://www.nitrc.org/projects/cleanline">CleanLine</a></li>
</ol>
<li>Resampling</li>
<li>Independent Components Analysis (ICA) with optional use of&nbsp;<a href="https://github.com/irenne/MARA">MARA</a>&nbsp;artifact classifier</li>
<li><a href="https://www.frontiersin.org/articles/10.3389/fnins.2018.00097/full">HAPPE Pipeline</a></li>
<ol>
<li>Select 10-20 channel locations, and other channels of interest</li>
<li>1 Hz high-pass filter</li>
<li>CleanLine to remove line noise</li>
<li>Wavelet cleaning</li>
<li>ICA with MARA</li>
<li>Interpolate bad channels</li>
<li>Average reference</li>
</ol>
<li>Re-Referencing</li>
<ol>
<li>Laplacian (<a href="http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/">CSDLP</a>)</li>
<li>Average re-referencing</li>
<li>Reference to individual or subset of electrodes</li>
<li><a href="https://www.frontiersin.org/articles/10.3389/fnins.2017.00601/full">REST</a></li>
</ol>
<li>Detrending</li>
<ol>
<li>Mean</li>
<li>Linear</li>
<li>Kalman</li>
</ol>
<li>Amplitude-based artifact detection</li>
<li>Segmentation</li>
<ol>
<li>Stimulus-locked (for task-related data)</li>
<li>Non-stimulus-locked (for continuous or &ldquo;resting&rdquo; data)</li>
</ol>
<li>Power spectral decomposition (PSD)</li>
<li>Inter-trial phase coherence (ITPC)</li>
</ol>
<p>BEAPP aims to strike a balance between assuming only a basic level of MATLAB and EEG signal processing experience, while also offering a flexible menu of opportunities for more advanced users.&nbsp; At a minimum, no programming experience is required to use BEAPP, but basic familiarity with troubleshooting in Matlab will likely come in handy.</p>
<p>User guides for running BEAPP programmatically and using a GUI can be found in the documentation folder.</p>
<p><strong>Next Steps:</strong></p>
<p>BEAPP is intended to be a dynamic, rather than static, platform for EEG processing.&nbsp; This means that we plan to continue adding additional functionality over time, and we encourage other users to add functionality as well.&nbsp;</p>
<p>&nbsp;</p>
<p><strong>What&rsquo;s on Our Wishlist (coming soon):</strong></p>
<ol>
<li>Improved GUI for user inputs</li>
<li>Formatted dataset-wide run reporting (general dataset statistics, formatted warnings in a report)</li>
<li>Reading files in directly from .bdf/.edf and .set files</li>
<li>Coherence</li>
<li>Phase lag index</li>
<li>Topoplotting outputs with mixed source acquisition layouts/ number of channels</li>
<li>Phase amplitude coupling</li>
<li>Ability to change the order of modules</li>
</ol>
<p>&nbsp;In publications, please reference: Levin AR, M&eacute;ndez Leal AS, Gabard-Durnam LJ, and O'Leary, HM. BEAPP: The Batch Electroencephalography Automated Processing Platform. Frontiers in Neuroscience (2018).</p>
<p>Correspondence: April R. Levin, MD&nbsp;<a href="mailto:april.levin@childrens.harvard.edu">april.levin@childrens.harvard.edu</a></p>
<p><strong>The Batch Electroencephalography Automated Processing Platform (BEAPP)</strong> Copyright (C) 2015, 2016, 2017, 2018</p>
<p>Developed at Boston Children's Hospital Department of Neurology and the Laboratories of Cognitive Neuroscience</p>
<p>All rights reserved.</p>
<p>This software is being distributed with the hope that it will be useful, but WITHOUT ANY WARRANTY; without even implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General Public License for more details.</p>
<p>In no event shall Boston Children&rsquo;s Hospital (BCH), the BCH Department of Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software contributors to BEAPP be liable to any party for direct, indirect, special, incidental, or consequential damages, including lost profits, arising out of the use of this software and its documentation, even if Boston Children&rsquo;s Hospital, the Laboratories of Cognitive Neuroscience, and software contributors have been advised of the possibility of such damage. Software and documentation is provided &ldquo;as is.&rdquo; Boston Children&rsquo;s Hospital, the Laboratories of Cognitive Neuroscience, and software contributors are under no obligation to provide maintenance, support, updates, enhancements, or modifications.</p>
<p>This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License (version 3) as published by the Free Software Foundation.</p>
<p>You should receive a copy of the GNU General Public License along with this program. If not, see&nbsp;<a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a>.</p>
<p><strong>Additional Credits: </strong></p>
<p>BEAPP utilizes functionality from the software listed below. Users who choose to run any of this software through BEAPP should cite the appropriate papers in any publications.</p>
<p><a href="http://sccn.ucsd.edu/wiki/EEGLAB_revision_history_version_14">EEGLAB Version 14.1.2b</a>:</p>
<p>Delorme A &amp; Makeig S (2004) EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics. Journal of Neuroscience Methods 134:9-21</p>
<p><a href="https://github.com/VisLab/EEG-Clean-Tools">PREP pipeline Version 0.52:&nbsp;</a></p>
<p>Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015) The PREP pipeline: standardized preprocessing for large-scale EEG analysis Front. Neuroinform. 9:16. doi: 10.3389/fninf.2015.00016</p>
<p><a href="http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/">CSD Toolbox:&nbsp;</a></p>
<p>Kayser, J., Tenke, C.E. (2006). Principal components analysis of Laplacian waveforms as a generic method for identifying ERP generator patterns: I. Evaluation with auditory oddball tasks. Clinical Neurophysiology, 117(2), 348-368</p>
<p>Users using low-resolution (less than 64 channel) montages with the CSD toolbox should also cite: Kayser, J., Tenke, C.E. (2006). Principal components analysis of Laplacian waveforms as a generic method for identifying ERP generator patterns: II. Adequacy of low-density estimates. Clinical Neurophysiology, 117(2), 369-380</p>
<p><a href="https://www.frontiersin.org/articles/10.3389/fnins.2018.00097/full">HAPPE</a>:</p>
<p>Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., &amp; Levin, A. R. (2018). The Harvard Automated Processing Pipeline for Electroencephalography (HAPPE): standardized processing software for developmental and high-artifact data. Frontiers in Neuroscience (2018).</p>
<p><a href="https://www.frontiersin.org/articles/10.3389/fnins.2017.00601/full">The REST Toolbox</a>:</p>
<p>&nbsp;Li Dong*, Fali Li, Qiang Liu, Xin Wen, Yongxiu Lai, Peng Xu and Dezhong Yao*. MATLAB Toolboxes for Reference Electrode Standardization Technique (REST) of Scalp EEG. Frontiers in Neuroscience, 2017:11(601).</p>
<p><a href="https://irenne.github.io/artifacts/">MARA</a>:</p>
<p>Winkler et al., Automatic Classification of Artifactual ICA-Components for Artifact Removal in EEG Signals. Behavioral and Brain Functions 7:30 (2011).</p>
<p><a href="http://www.nitrc.org/projects/cleanline">CleanLine</a>:</p>
<p>Mullen, T. (2012).&nbsp;<em>NITRC: CleanLine: Tool/Resource Info</em>.</p>
<p><strong>Requirements:</strong></p>
<p>&nbsp;BEAPP was written in Matlab 2016a. Older versions of Matlab may not support certain functions used in BEAPP.</p>
<p>&nbsp;</p>
