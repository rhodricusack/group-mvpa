% Automatic analysis
% PCAMVPA Rhodri Cusack April 2012

addpath('/home/rcusack/FastICA_25/')

aap=aarecipe('aap_tasklist_movieica_cambridgepreproc_pcmvpa.xml');

aap=aas_localconfig(aap);

aap.directory_conventions.subject_directory_format=1;

% DEFINE STUDY SPECIFIC PARAMETERS
aap.options.aa_minver=4.0;
addpath /home/rcusack/software/aa/versions/release-4.0-beta % will only work on aa version 4.0 or above

% Location of raw DICOM data
%aap.directory_conventions.rawdatadir='/home/rcusack/forvivek';

% Where to put the analyzed data 
aap.acq_details.root = '/home/rcusack/camcan/movieica';
aap.directory_conventions.analysisid='pcamvpa';


aap_remote=load('/home/rcusack/camcan/movieica/data/test1/aamod_bet_epi_reslicing_00001/remote_aap_parameters.mat')
aap_remote=aap_remote.aap
aap.acq_details.subjects=aap_remote.acq_details.subjects(1:64);
%aap.acq_details.sessions=aap_remote.acq_details.sessions;

% The subjects (which scans needed: 7-11, 15?)
% this might be useful ls -d CBU*/*/*MEPI5*
%aap=aas_addsubject(aap,'CBU110254_MR10033_CC310008',{[6:10]});

% One session
aap=aas_addsession(aap,'movie');

% DO PROCESSING
aa_doprocessing(aap);
