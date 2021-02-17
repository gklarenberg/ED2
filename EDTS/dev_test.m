%==========================================================================
% Program: dev_test.m
%
% This script runs a suit of checks on EDM output.  The purpose
% of the checks is to compare newly developed model runs to the
% the mainline.
%
% Please read the README file for more information
%
%==========================================================================

clear all;
close all;

%==========================================================================
%     User defined variables
%==========================================================================

test_name = '3e31dd3-xyz-b13aac2-v1_rapid';

use_m34 = true;       % POI Manaus km34
use_ata = true;       % POI Atacama
use_s67 = true;       % POI Santarem km 67
use_har = true;       % POI Harvard Forest
use_pdg = true;       % POI Pe de Gigante
use_cax = true;       % POI Caxiuana
use_ton = true;       % POI Tonzi (temperate)
use_tnf = true;       % POI Tapajos National Forest
use_gyf = true;       % POI Paracou
use_s83 = true;       % POI Santarem km 83 (logging)
use_prg = true;       % POI Paragominas (thousands of patches)
use_pet = true;       % POI Petrolina
use_tl2 = true;       % POI Toolik (boreal)
use_hbg = true;       % POI Harvard (Bare Ground)
use_hip = true;       % POI Petrolina (short high frequency)
use_him = true;       % POI Manaus (short high frequency)
use_hig = true;       % POI Paracou (short high frequency)
use_hih = true;       % POI Harvard (short high frequency)
use_rjg = true;       % GRIDDED centered on Rebio Jaru


%==========================================================================================%



site_name  = {'Manaus km 34',...
              'Atacama Desert',...
              'Santarem km 67',...
              'Harvard Forest',...
              'Pe de Gigante',...
              'Caxiuana',...
              'Tonzi',...
              'Tapajos National Forest',...
              'Paracou',...
              'Santarem Km 83',...
              'Paragominas',...
              'Petrolina',...
              'Toolik',...
              'Harvard Bare Ground'};

siteid     = {'m34',...
              'ata',...
              's67',...
              'har',...
              'pdg',...
              'cax',...
              'ton',...
              'tnf',...
              'gyf',...
              's83',...
              'prg',...
              'pet',...
              'tl2',...
              'hbg'};

hifr_name = {'Petrolina HF','Manaus HF','Paracou HF','Harvard HF'};
hifrid    = {'hip','him','hig','hih'};


gridid     = {'rjg'};
grid_name  = {'12x12 Offline Grid - Rebio Jaru'};

addpath(strcat(pwd,'/dt_scripts'));
addpath(strcat(pwd,'/dt_scripts/cbfreeze'));
addpath(strcat(pwd,'/dt_scripts/exportfig'));


%==========================================================================================%

%set(0,'DefaultAxesFontName','Courier 10 Pitch');
visible = 'off';
addpath('dt_scripts');
testglobals;
outdir = strcat(test_name,'/report/');
mkdir(outdir);


nsite = numel(siteid);
nhifr = numel(hifrid);
ngrid = numel(gridid);


%==========================================================================================%
% Read in the xml data to help write the report
%==========================================================================================%

xmlfile = strcat(test_name,'/test_text.xml');
try
    xmltree = xmlread(xmlfile);
catch
    error('Failed to read XML file: %s',xmlfile);
end

xmlitems = xmltree.getElementsByTagName('description');
xmlitem0 = xmlitems.item(0);
branch_item = xmlitem0.getElementsByTagName('branch_version');
branch_version = char(branch_item.item(0).getFirstChild.getData);
committer_item = xmlitem0.getElementsByTagName('committer_name');
committer_name = char(committer_item.item(0).getFirstChild.getData);
tester_item = xmlitem0.getElementsByTagName('tester_name');
tester_name = char(tester_item.item(0).getFirstChild.getData);
test_item          = xmlitem0.getElementsByTagName('test_description');
test_description   = char(test_item.item(0).getFirstChild.getData);


%==========================================================================================%
%  Determine the status of the runs
%  If not *_out files exist in the report, then don't use this one
%  Use the check script? COMP-FAILED-RUNNING-DNEXIST
%==========================================================================================%

display(sprintf('\nThe following sites will be assessed:\n'));

use_site = [use_m34,use_ata,use_s67,...
            use_har,use_pdg,use_cax,...
            use_ton,use_tnf,use_gyf,...
            use_s83,use_prg,use_pet,...
            use_tl2,use_hbg];
        
use_hifr = [use_hip,use_him,use_hig,use_hih];

use_grid = [use_rjg];

for is=1:nsite
    testout_srch = sprintf('%s/test_%s.',test_name,siteid{is});
    mainout_srch = sprintf('%s/main_%s.',test_name,siteid{is});
    dbugout_srch = sprintf('%s/dbug_%s.',test_name,siteid{is});
    
    srch_test=dir(strcat(testout_srch,'*out'));
    srch_dbug=dir(strcat(dbugout_srch,'*out'));
    srch_main=dir(strcat(mainout_srch,'*out'));
    
    
    if (isempty(srch_test) | isempty(srch_dbug) | isempty(srch_main))
        use_site(is)=false;
        continue
    else
        
        testout_str=sprintf('%s/%s',test_name,srch_test(end).name);
        dbugout_str=sprintf('%s/%s',test_name,srch_dbug(end).name);
        mainout_str=sprintf('%s/%s',test_name,srch_main(end).name);
        
        if(use_site(is))
            if (exist(testout_str,'file') && exist(mainout_str,'file') && ...
                exist(dbugout_str,'file'))
                use_site(is)=true;
                display(sprintf('%s - %s',siteid{is},site_name{is}));
            else
                use_site(is)=false;
            end
        end
    end
end

for ih=1:nhifr
    testout_srch = sprintf('%s/test_%s.',test_name,hifrid{ih});
    mainout_srch = sprintf('%s/main_%s.',test_name,hifrid{ih});
    dbugout_srch = sprintf('%s/dbug_%s.',test_name,hifrid{ih});
    
    
    srch_test=dir(strcat(testout_srch,'*out'));
    srch_dbug=dir(strcat(dbugout_srch,'*out'));
    srch_main=dir(strcat(mainout_srch,'*out'));
    
    
    if (isempty(srch_test) | isempty(srch_dbug) | isempty(srch_main))
        
        use_site(ih)=false;
        continue
        
    else
        
        testout_str=sprintf('%s/%s',test_name,srch_test(end).name);
        dbugout_str=sprintf('%s/%s',test_name,srch_dbug(end).name);
        mainout_str=sprintf('%s/%s',test_name,srch_main(end).name);
        
        if(use_hifr(ih))
            if (exist(testout_str,'file') && exist(mainout_str,'file') && ...
                exist(dbugout_str,'file'))
                use_hifr(ih)=true;
                display(sprintf('%s - %s',hifrid{ih},hifr_name{ih}));
            else
                use_hifr(ih)=false;
            end
        end
    end
end

for ig=1:ngrid
    
    testout_srch = sprintf('%s/test_%s.',test_name,gridid{ig});
    mainout_srch = sprintf('%s/main_%s.',test_name,gridid{ig});
    dbugout_srch = sprintf('%s/dbug_%s.',test_name,gridid{ig});

    srch_test=dir(strcat(testout_srch,'*out'));
    srch_dbug=dir(strcat(dbugout_srch,'*out'));
    srch_main=dir(strcat(mainout_srch,'*out'));

    if (isempty(srch_test) | isempty(srch_dbug) | isempty(srch_main))
        use_site(ig)=false;
        continue
    else
        testout_str=sprintf('%s/%s',test_name,srch_test(end).name);
        dbugout_str=sprintf('%s/%s',test_name,srch_dbug(end).name);
        mainout_str=sprintf('%s/%s',test_name,srch_main(end).name);
        if(use_grid(ig))
            if (exist(testout_str,'file') && exist(mainout_str,'file') && ...
                exist(dbugout_str,'file'))
                use_grid(ig)=true;
                display(sprintf('%s - %s',gridid{ig},grid_name{ig}));
            else
                use_grid(ig)=false;
            end
        end
    end
end

display(sprintf('\nThe Following sites are not available:\n'));
ii=0;
for is=1:nsite
    if(~use_site(is))
        display(sprintf('%s - %s\n',siteid{is},site_name{is}));
        ii=ii+1;
    end
end

for ih=1:nhifr
    if(~use_hifr(ih))
        display(sprintf('%s - %s\n',hifrid{ih},hifr_name{ih}));
        ii=ii+1;
    end
end

for ig=1:ngrid
    if(~use_grid(ig))
        display(sprintf('%s - %s\n',gridid{ig},grid_name{ig}));
        ii=ii+1;
    end
end

if(ii==0)
    display(sprintf('None'));
end


% Create a new list of the sites that some output was generated

nsiteid={};
ngridid={};
nhifrid={};
temp_name = site_name;
site_name = {};
is=0;
for ii=1:nsite
    if(use_site(ii))
        is=is+1;
        nsiteid{is} = siteid{ii};
        site_name{is} = temp_name{ii};
    end
end

temp_name = grid_name;
grid_name = {};
ig=0;
for ii=1:ngrid
    if(use_grid(ii))
        ig=ig+1;
        ngridid{ig} = gridid{ii};
        grid_name{ig} = temp_name{ii};
    end
end

temp_name = hifr_name;
hifr_nam  = {};
ih=0;
for ii=1:nhifr
    if(use_hifr(ii))
        ih=ih+1;
        nhifrid{ih} = hifrid{ii};
        hifr_name{ih} = temp_name{ii};
    end
end

hifrid = nhifrid;clear nhifrid;
gridid = ngridid;clear ngridid;
siteid = nsiteid;clear nsiteid;

nsite = is;
ngrid = ig;
nhifr = ih;

runstat = {'Pending','Running','Success','SIGSEGV','CRASHED','BADBDGT','BADMETD','METMISS','STOPPED'};
pause(2);


%==========================================================================================%
% Part 0 - Check whether simulations have completed
%==========================================================================================%

display(sprintf('\nChecking Simulations for Completion\n'));

if (nsite > 0)
   spass=zeros(nsite,3);
   sshow=false(nsite);
end
if (ngrid > 0)
   gpass=zeros(ngrid,3);
   gshow=false(ngrid);
end
if (nhifr > 0)
   hpass=zeros(nhifr,3);
   hshow=false(nhifr);
end


%------------------------------------------------------------------------------------------%
% Sites of Interest (SOI)
%------------------------------------------------------------------------------------------%
if (nsite > 0)

    for is=1:nsite
        %----------------------------------------------------------------------------------%
        %  DBUG: 
        %----------------------------------------------------------------------------------%
        % Check regular output file
        dbugout_srch  = sprintf('%s/dbug_%s.',test_name,siteid{is});
        outsrch=dir(strcat(dbugout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (spass(is,1) == 0)
               spass(is,1) = 1;
            end
            if (strfind(tline,'execution ends'))
               spass(is,1) = 2;
            elseif (strfind(tline,'sigsegv'))
               spass(is,1) = 3;
            elseif (strfind(tline,'segmentation fault'))
               spass(is,1) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               spass(is,1) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               spass(is,1) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               spass(is,1) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               spass(is,1) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               spass(is,1) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               spass(is,1) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(dbugout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  spass(is,1) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  spass(is,1) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------



        % ---------------------------------------------------------------------
        %  TEST: 
        % ---------------------------------------------------------------------
        % Check regular output file
        testout_srch  = sprintf('%s/test_%s.',test_name,siteid{is});
        outsrch=dir(strcat(testout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (spass(is,2) == 0)
               spass(is,2) = 1;
            end
            if (strfind(tline,'execution ends'))
               spass(is,2) = 2;
            elseif (strfind(tline,'sigsegv'))
               spass(is,2) = 3;
            elseif (strfind(tline,'segmentation fault'))
               spass(is,2) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               spass(is,2) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               spass(is,2) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               spass(is,2) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               spass(is,2) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               spass(is,2) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               spass(is,2) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(testout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  spass(is,2) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  spass(is,2) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------




        % ---------------------------------------------------------------------
        %  MAIN: 
        % ---------------------------------------------------------------------
        % Check regular output file
        mainout_srch  = sprintf('%s/main_%s.',test_name,siteid{is});
        outsrch=dir(strcat(mainout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (spass(is,3) == 0)
               spass(is,3) = 1;
            end
            if (strfind(tline,'execution ends'))
               spass(is,3) = 2;
            elseif (strfind(tline,'sigsegv'))
               spass(is,3) = 3;
            elseif (strfind(tline,'segmentation fault'))
               spass(is,3) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               spass(is,3) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               spass(is,3) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               spass(is,3) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               spass(is,3) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               spass(is,3) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               spass(is,3) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(mainout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  spass(is,3) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  spass(is,3) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------

        display(sprintf('%s - dbug:%s test:%s main:%s ',...
            siteid{is},runstat{spass(is,1)+1}, ...
            runstat{spass(is,2)+1}, ...
            runstat{spass(is,3)+1}));
        
    end
end
% -----------------------------------------------------------------------------




% -----------------------------------------------------------------------------
% Gridded Simulations
% -----------------------------------------------------------------------------
if (ngrid > 0)
    for ig=1:ngrid

        % ---------------------------------------------------------------------
        %  DBUG: 
        % ---------------------------------------------------------------------
        % Check regular output file
        dbugout_srch  = sprintf('%s/dbug_%s.',test_name,gridid{ig});
        outsrch=dir(strcat(dbugout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (gpass(ig,1) == 0)
               gpass(ig,1) = 1;
            end
            if (strfind(tline,'execution ends'))
               gpass(ig,1) = 2;
            elseif (strfind(tline,'sigsegv'))
               gpass(ig,1) = 3;
            elseif (strfind(tline,'segmentation fault'))
               gpass(ig,1) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               gpass(ig,1) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               gpass(ig,1) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               gpass(ig,1) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               gpass(ig,1) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               gpass(ig,1) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               gpass(ig,1) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(dbugout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  gpass(ig,1) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  gpass(ig,1) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------



        % ---------------------------------------------------------------------
        %  TEST: 
        % ---------------------------------------------------------------------
        % Check regular output file
        testout_srch  = sprintf('%s/test_%s.',test_name,gridid{ig});
        outsrch=dir(strcat(testout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (gpass(ig,2) == 0)
               gpass(ig,2) = 1;
            end
            if (strfind(tline,'execution ends'))
               gpass(ig,2) = 2;
            elseif (strfind(tline,'sigsegv'))
               gpass(ig,2) = 3;
            elseif (strfind(tline,'segmentation fault'))
               gpass(ig,2) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               gpass(ig,2) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               gpass(ig,2) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               gpass(ig,2) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               gpass(ig,2) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               gpass(ig,2) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               gpass(ig,2) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(testout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  gpass(ig,2) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  gpass(ig,2) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------

        % ---------------------------------------------------------------------
        %  MAIN: 
        % ---------------------------------------------------------------------
        % Check regular output file
        mainout_srch  = sprintf('%s/main_%s.',test_name,gridid{ig});
        outsrch=dir(strcat(mainout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (gpass(ig,3) == 0)
               gpass(ig,3) = 1;
            end
            if (strfind(tline,'execution ends'))
               gpass(ig,3) = 2;
            elseif (strfind(tline,'sigsegv'))
               gpass(ig,3) = 3;
            elseif (strfind(tline,'segmentation fault'))
               gpass(ig,3) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               gpass(ig,3) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               gpass(ig,3) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               gpass(ig,3) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               gpass(ig,3) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               gpass(ig,3) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               gpass(ig,3) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(mainout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  gpass(ig,3) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  gpass(ig,3) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------
        
        display(sprintf('%s - dbug:%s test:%s main:%s ',...
            gridid{ig},runstat{gpass(ig,1)+1}, ...
            runstat{gpass(ig,2)+1}, ...
            runstat{gpass(ig,3)+1}));
    end
end
% -----------------------------------------------------------------------------




% -----------------------------------------------------------------------------
% High-frequency simulations
% -----------------------------------------------------------------------------
if (nhifr > 0)
    for ih=1:nhifr
        % ---------------------------------------------------------------------
        %  DBUG: 
        % ---------------------------------------------------------------------
        % Check regular output file
        dbugout_srch  = sprintf('%s/dbug_%s.',test_name,hifrid{ih});
        outsrch=dir(strcat(dbugout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (hpass(ih,1) == 0)
               hpass(ih,1) = 1;
            end
            if (strfind(tline,'execution ends'))
               hpass(ih,1) = 2;
            elseif (strfind(tline,'sigsegv'))
               hpass(ih,1) = 3;
            elseif (strfind(tline,'segmentation fault'))
               hpass(ih,1) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               hpass(ih,1) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               hpass(ih,1) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               hpass(ih,1) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               hpass(ih,1) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               hpass(ih,1) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               hpass(ih,1) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(dbugout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  hpass(ih,1) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  hpass(ih,1) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------




        % ---------------------------------------------------------------------
        %  TEST: 
        % ---------------------------------------------------------------------
        % Check regular output file
        testout_srch  = sprintf('%s/test_%s.',test_name,hifrid{ih});
        outsrch=dir(strcat(testout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (hpass(ih,2) == 0)
               hpass(ih,2) = 1;
            end
            if (strfind(tline,'execution ends'))
               hpass(ih,2) = 2;
            elseif (strfind(tline,'sigsegv'))
               hpass(ih,2) = 3;
            elseif (strfind(tline,'segmentation fault'))
               hpass(ih,2) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               hpass(ih,2) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               hpass(ih,2) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               hpass(ih,2) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               hpass(ih,2) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               hpass(ih,2) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               hpass(ih,2) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(testout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  hpass(ih,2) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  hpass(ih,2) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------




        % ---------------------------------------------------------------------
        %  MAIN: 
        % ---------------------------------------------------------------------
        % Check regular output file
        mainout_srch  = sprintf('%s/main_%s.',test_name,hifrid{ih});
        outsrch=dir(strcat(mainout_srch,'*out'));
        outfile=sprintf('%s/%s',test_name,outsrch(end).name);
        fid=fopen(outfile);
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
               break
            elseif (hpass(ih,3) == 0)
               hpass(ih,3) = 1;
            end
            if (strfind(tline,'execution ends'))
               hpass(ih,3) = 2;
            elseif (strfind(tline,'sigsegv'))
               hpass(ih,3) = 3;
            elseif (strfind(tline,'segmentation fault'))
               hpass(ih,3) = 3;
            elseif (strfind(tline,'IFLAG1 problem'))
               hpass(ih,3) = 4;
            elseif (strfind(tline,'Budget check has failed'))
               hpass(ih,3) = 5;
            elseif (strfind(tline,'Meteorological forcing has issues'))
               hpass(ih,3) = 6;
            elseif (strfind(tline,'Specify ED_MET_DRIVER_DB properly'))
               hpass(ih,3) = 7;
            elseif (strfind(tline,'Cannot open met driver input file'))
               hpass(ih,3) = 7;
            elseif(  strfind(tline,'FATAL ERROR'))
               hpass(ih,3) = 8;
            end
        end
        fclose(fid);
        % Check error output file in case it exists
        errsrch=dir(strcat(mainout_srch,'*err'));
        errfile=sprintf('%s/%s',test_name,errsrch(end).name);
        if (exist(errfile,'file') == 2)
           fid=fopen(outfile);
           while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               if (strfind(tline,'sigsegv'))
                  hpass(ih,3) = 3;
               elseif (strfind(tline,'segmentation fault'))
                  hpass(ih,3) = 3;
               end
           end
           fclose(fid);
        end
        % ---------------------------------------------------------------------

        display(sprintf('%s - dbug:%s test:%s main:%s ',...
            hifrid{ih},runstat{hpass(ih,1)+1}, ...
            runstat{hpass(ih,2)+1}, ...
            runstat{hpass(ih,3)+1}));
    end
end

%==========================================================================
% PART 1: Loop through POIs
%==========================================================================

if (nsite > 0)

   display(sprintf('\nCheck POI Fluxes, Succession and Profiles'));

   latex_ftab = zeros(9,nsite);
   latex_fname = {'$\\Delta ET$','$\\Delta SHF$','$\\Delta R_{net}$','$\\Delta R_{SWU}$'...
                 ,'$\\Delta GPP$','$\\Delta NEP$','$\\Delta CO2_{C}$'...
                 ,'$\\Delta \\theta_{50cm}$','$\\Delta T_L$'};
   latex_funit = {'$[mm/day]$','$[W/m^2]$','$[W/m^2]$','$[W/m^2]$'...
                 ,'$[kgC/m^2]$','$[kgC/m^2]$','$[ppm]$','$[m^3/m^3]$','$[^oC]$'};

   for is = 1:nsite
      test_q_pfx = sprintf('%s/F_test_%s/test_%s-Q-',test_name,siteid{is},siteid{is});
      cont_q_pfx = sprintf('%s/F_main_%s/main_%s-Q-',test_name,siteid{is},siteid{is});
      test_s_pfx = sprintf('%s/S_test_%s/test_%s-S-',test_name,siteid{is},siteid{is});
      cont_s_pfx = sprintf('%s/S_main_%s/main_%s-S-',test_name,siteid{is},siteid{is});
      
      id=strfind(test_q_pfx,'/');
      test_q_dir = test_q_pfx(1:id(end));
      
      id=strfind(test_s_pfx,'/');
      test_s_dir = test_s_pfx(1:id(end));
      
      id=strfind(cont_q_pfx,'/');
      cont_q_dir = cont_q_pfx(1:id(end));
      
      id=strfind(cont_s_pfx,'/');
      cont_s_dir = cont_s_pfx(1:id(end));
      
      test_q_flist = dir(strcat(test_q_pfx,'*h5'));
      cont_q_flist = dir(strcat(cont_q_pfx,'*h5'));
      test_s_flist = dir(strcat(test_s_pfx,'*h5'));
      cont_s_flist = dir(strcat(cont_s_pfx,'*h5'));
      
      nqfiles     = min([length(cont_q_flist) length(test_q_flist)]);
      nsfiles     = min([length(cont_s_flist) length(test_s_flist)]);

      display(sprintf('Site %s -- File count.  Analyses = %i; Restarts = %i.'...
                     ,siteid{is},nqfiles,nsfiles));

      if ( (nqfiles > 2) && (nsfiles > 2) )
         dnq       = zeros(nqfiles,1);
         dns       = zeros(nsfiles,1);
         sshow(is) = true;

         %==================================================================
         % Comparison of Flux Variables
         %==================================================================
         
         for it=1:nqfiles
               
            tqfile = strcat(test_q_dir,test_q_flist(it).name);
            cqfile = strcat(cont_q_dir,cont_q_flist(it).name);
            
            iyear  = str2double(tqfile(end-23:end-20));
            imonth = str2double(tqfile(end-18:end-17));
            idate  = str2double(tqfile(end-15:end-14));
            ihour  = str2double(tqfile(end-12:end-11));
            iminute= str2double(tqfile(end-10:end-9));
            isecond= str2double(tqfile(end-8:end-7));
            
            dnq(it) = datenum(iyear,imonth,idate,ihour,iminute,isecond);
            
            iyear  = str2double(cqfile(end-23:end-20));
            imonth = str2double(cqfile(end-18:end-17));
            idate  = str2double(cqfile(end-15:end-14));
            ihour  = str2double(cqfile(end-12:end-11));
            iminute= str2double(cqfile(end-10:end-9));
            isecond= str2double(cqfile(end-8:end-7));
            
            if (datenum(iyear,imonth,idate,ihour,iminute,isecond)~=dnq(it))
               display('Q-File Time Mismatch, check you directories');
               display('and the prefixes');
               return;
            end
            
            if (it==nqfiles)
                iyearz=iyear;
            end

            if (it == 1)

               iyeara=iyear;
               nhrs = numel(hdf5read(tqfile,'/QMEAN_VAPOR_AC_PY'));

               tmp = -hdf5read(tqfile,'/SLZ');
               k50 = find(tmp>0.5,1,'last');
               nz = numel(tmp);
               dz = zeros(nz,1);
               for iz=1:nz-1
                   dz(iz)=tmp(iz)-tmp(iz+1);
               end
               dz(nz) = tmp(nz); 
               slz=zeros(nz,nhrs);
               for ihr=1:nhrs
                   slz(:,ihr)=dz;
               end


               phrs = linspace(24/nhrs,24,nhrs);
               npts = nqfiles*nhrs;
               nmos    = zeros(12,1);
               
               flux_tp = zeros(npts,5);
               flux_td = zeros(nhrs,5);
               flux_tm = zeros(12,5);
               flux_cp = zeros(npts,5);
               flux_cd = zeros(nhrs,5);
               flux_cm = zeros(12,5);
               
               % FAST_SOIL_C, SLOW_SOIL_C,
               
               state_tp = zeros(npts,5);
               state_td = zeros(nhrs,5);
               state_tm = zeros(12,5);
               state_cp = zeros(npts,5);
               state_cd = zeros(nhrs,5);
               state_cm = zeros(12,5);
               
               flux_names = {'ET',...
                   'SHF',...
                   'R_{net}',...
                   'R_{SWU}',...
                   'R_{LWU}'};
               
               state_names = {'GPP',...
                   'NEP',...
                   'Canopy CO2',...
                   '50cm Soil Moisture'...
                   'Leaf Temp'};
               
               flux_units =    {'[mm/m^2/mo]',...
                   '[W/m^2]',...
                   '[W/m^2]',...
                   '[W/m^2]',...
                   '[W/m^2]'};
               
               state_units = {'[kgC/m^2/yr]',...
                   '[kgC/m^2/yr]'...
                   '[ppm]',...
                   '[m^3/m^3]',...
                   '[^oC]'};

            end

            id1 = (it-1)*nhrs+1;
            id2 = (it*nhrs);
            nmos(imonth)=nmos(imonth)+1;
            
            itmp=1;
            tmp = hdf5read(tqfile,'/QMEAN_VAPOR_AC_PY')*-86400;
            flux_tp(id1:id2,itmp) = tmp;
            flux_td(:,itmp)      = flux_td(:,itmp) + tmp./nqfiles;
            flux_tm(imonth,itmp) = flux_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_VAPOR_AC_PY')*-86400;
            flux_cp(id1:id2,itmp) = tmp;
            flux_cd(:,itmp)      = flux_cd(:,itmp) + tmp./nqfiles;
            flux_cm(imonth,itmp) = flux_cm(imonth,itmp)+mean(tmp);
            
            itmp=2;
            tmp = -hdf5read(tqfile,'/QMEAN_SENSIBLE_AC_PY');
            flux_tp(id1:id2,itmp) = tmp;
            flux_td(:,itmp)      = flux_td(:,itmp) + tmp./nqfiles;
            flux_tm(imonth,itmp) = flux_tm(imonth,itmp)+mean(tmp);
            
            tmp = -hdf5read(cqfile,'/QMEAN_SENSIBLE_AC_PY');
            flux_cp(id1:id2,itmp) = tmp;
            flux_cd(:,itmp)      = flux_cd(:,itmp) + tmp./nqfiles;
            flux_cm(imonth,itmp) = flux_cm(imonth,itmp)+mean(tmp);
            
            itmp=3;
            tmp = hdf5read(tqfile,'/QMEAN_RNET_PY');
            flux_tp(id1:id2,itmp) = tmp;
            flux_td(:,itmp)      = flux_td(:,itmp) + tmp./nqfiles;
            flux_tm(imonth,itmp) = flux_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_RNET_PY');
            flux_cp(id1:id2,itmp) = tmp;
            flux_cd(:,itmp)      = flux_cd(:,itmp) + tmp./nqfiles;
            flux_cm(imonth,itmp) = flux_cm(imonth,itmp)+mean(tmp);
            
            itmp=4;
            tmp = hdf5read(tqfile,'/QMEAN_RSHORTUP_PY');
            flux_tp(id1:id2,itmp) = tmp;
            flux_td(:,itmp)      = flux_td(:,itmp) + tmp./nqfiles;
            flux_tm(imonth,itmp) = flux_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_RSHORTUP_PY');
            flux_cp(id1:id2,itmp) = tmp;
            flux_cd(:,itmp)      = flux_cd(:,itmp) + tmp./nqfiles;
            flux_cm(imonth,itmp) = flux_cm(imonth,itmp)+mean(tmp);
            
            itmp=5;
            tmp = hdf5read(tqfile,'/QMEAN_RLONGUP_PY');
            flux_tp(id1:id2,itmp) = tmp;
            flux_td(:,itmp)      = flux_td(:,itmp) + tmp./nqfiles;
            flux_tm(imonth,itmp) = flux_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_RLONGUP_PY');
            flux_cp(id1:id2,itmp) = tmp;
            flux_cd(:,itmp)      = flux_cd(:,itmp) + tmp./nqfiles;
            flux_cm(imonth,itmp) = flux_cm(imonth,itmp)+mean(tmp);
            
            itmp=1;
            tmp = hdf5read(tqfile,'/QMEAN_GPP_PY');
            state_tp(id1:id2,itmp) = tmp;
            state_td(:,itmp)      = state_td(:,itmp) + tmp./nqfiles;
            state_tm(imonth,itmp) = state_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_GPP_PY');
            state_cp(id1:id2,itmp) = tmp;
            state_cd(:,itmp)      = state_cd(:,itmp) + tmp./nqfiles;
            state_cm(imonth,itmp) = state_cm(imonth,itmp)+mean(tmp);
            
            itmp=2;
            tmp = hdf5read(tqfile,'/QMEAN_NEP_PY');
            state_tp(id1:id2,itmp) = tmp;
            state_td(:,itmp)      = state_td(:,itmp) + tmp./nqfiles;
            state_tm(imonth,itmp) = state_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_NEP_PY');
            state_cp(id1:id2,itmp) = tmp;
            state_cd(:,itmp)      = state_cd(:,itmp) + tmp./nqfiles;
            state_cm(imonth,itmp) = state_cm(imonth,itmp)+mean(tmp);
            
            itmp=3;
            tmp = hdf5read(tqfile,'/QMEAN_CAN_CO2_PY');
            state_tp(id1:id2,itmp) = tmp;
            state_td(:,itmp)      = state_td(:,itmp) + tmp./nqfiles;
            state_tm(imonth,itmp) = state_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_CAN_CO2_PY');
            state_cp(id1:id2,itmp) = tmp;
            state_cd(:,itmp)      = state_cd(:,itmp) + tmp./nqfiles;
            state_cm(imonth,itmp) = state_cm(imonth,itmp)+mean(tmp);
            
            itmp=4;
            delz = sum(slz(k50:nz,1));
            tmp2d = hdf5read(tqfile,'/QMEAN_SOIL_WATER_PY');
            tmp   = sum(tmp2d(k50:nz,:).*slz(k50:nz,:),1)'./delz;
            state_tp(id1:id2,itmp) = tmp;
            state_td(:,itmp)      = state_td(:,itmp) + tmp./nqfiles;
            state_tm(imonth,itmp) = state_tm(imonth,itmp)+mean(tmp);
            
            tmp2d = hdf5read(cqfile,'/QMEAN_SOIL_WATER_PY');
            tmp   = sum(tmp2d(k50:nz,:).*slz(k50:nz,:),1)'./delz;
            state_cp(id1:id2,itmp) = tmp;
            state_cd(:,itmp)      = state_cd(:,itmp) + tmp./nqfiles;
            state_cm(imonth,itmp) = state_cm(imonth,itmp)+mean(tmp);
            
            itmp=5;
            tmp = hdf5read(tqfile,'/QMEAN_LEAF_TEMP_PY')-273.15;
            state_tp(id1:id2,itmp) = tmp;
            state_td(:,itmp)      = state_td(:,itmp) + tmp./nqfiles;
            state_tm(imonth,itmp) = state_tm(imonth,itmp)+mean(tmp);
            
            tmp = hdf5read(cqfile,'/QMEAN_LEAF_TEMP_PY')-273.15;
            state_cp(id1:id2,itmp) = tmp;
            state_cd(:,itmp)      = state_cd(:,itmp) + tmp./nqfiles;
            state_cm(imonth,itmp) = state_cm(imonth,itmp)+mean(tmp);

         end

         % Normalize means
         for imo=1:12
            flux_tm(imo,:) = flux_tm(imo,:)./nmos(imo);
            flux_cm(imo,:) = flux_cm(imo,:)./nmos(imo);
            state_tm(imo,:) = state_tm(imo,:)./nmos(imo);
            state_cm(imo,:) = state_cm(imo,:)./nmos(imo);
         end
         
         % Save means for the quick reference table
         latex_ftab(1,is) = mean(flux_tm(:,1))-mean(flux_cm(:,1));
         latex_ftab(2,is) = mean(flux_tm(:,2))-mean(flux_cm(:,2));
         latex_ftab(3,is) = mean(flux_tm(:,3))-mean(flux_cm(:,3));
         latex_ftab(4,is) = mean(flux_tm(:,4))-mean(flux_cm(:,4));
         latex_ftab(5,is) = mean(state_tm(:,1))-mean(state_cm(:,1));
         latex_ftab(6,is) = mean(state_tm(:,2))-mean(state_cm(:,2));
         latex_ftab(7,is) = mean(state_tm(:,3))-mean(state_cm(:,3));
         latex_ftab(8,is) = mean(state_tm(:,4))-mean(state_cm(:,4));
         latex_ftab(9,is) = mean(state_tm(:,5))-mean(state_cm(:,5));



         fluxes_img{is} = sprintf('%sfluxes_%s.eps',outdir,siteid{is});
         states_img{is} = sprintf('%sstates_%s.eps',outdir,siteid{is});
         
         titlestr = sprintf('%s (%4i - %4i)',site_name{is},iyeara,iyearz);

         % Make a plot
         %==================================================================
         plot_fluxes(flux_tp,flux_cp,flux_td,flux_cd,flux_tm,flux_cm...
                    ,flux_names,flux_units,phrs,titlestr,fluxes_img{is}...
                    ,runstat{spass(is,2)+1},runstat{spass(is,3)+1},visible);

         plot_states(state_tp,state_cp,state_td,state_cd,state_tm,state_cm...
                    ,state_names,state_units,phrs,titlestr,states_img{is}...
                    ,runstat{spass(is,2)+1},runstat{spass(is,3)+1},visible);
         %==================================================================


         %==================================================================
         % End stage biomass POI
         %==================================================================
         tsfile = strcat(test_s_dir,test_s_flist(nsfiles).name);
         csfile = strcat(cont_s_dir,cont_s_flist(nsfiles).name);

         testfig = sprintf('%sprofbar_test_%s',outdir,siteid{is});
         edpoi_biostat(tsfile,1,sprintf('test-%s',siteid{is}),testfig...
                      ,runstat{spass(is,2)+1},visible,2);
        
         contfig = sprintf('%sprofbar_main_%s',outdir,siteid{is});
         edpoi_biostat(csfile,1,sprintf('main-%s',siteid{is}),contfig...
                      ,runstat{spass(is,3)+1},visible,1);
        
         strcomp_timg{is} = sprintf('%s.eps',testfig);
         strcomp_cimg{is} = sprintf('%s.eps',contfig);

         strcomp_img{is} = sprintf('%sprofbar_%s.eps',outdir,siteid{is});

         % Concatenate the images

         [image1,map1] = imread(sprintf('%s.png',contfig));
         [image2,map2] = imread(sprintf('%s.png',testfig));
        
         iwidth = max(size(image1,2),size(image2,2));
         if (size(image1,2) < iwidth)
            image1(1,iwidth,1) = 0;
         end
         if (size(image2,2) < iwidth)
            image2(1,iwidth,1) = 0;
         end
         image3 = cat(2,image1,image2);
         bpfig = figure('Visible','off');

         image(image3);
         saveas(bpfig,strcomp_img{is},'eps2c')


         %==============================================================
         % Successional dynamics
         %==============================================================
         
         for it=1:nsfiles
            
            tsfile = strcat(test_s_dir,test_s_flist(it).name);
            csfile = strcat(cont_s_dir,cont_s_flist(it).name);
            
            iyear  = str2double(tsfile(end-23:end-20));
            imonth = str2double(tsfile(end-18:end-17));
            idate  = str2double(tsfile(end-15:end-14));
            ihour  = str2double(tsfile(end-12:end-11));
            iminute= str2double(tsfile(end-10:end-9));
            isecond= str2double(tsfile(end-8:end-7));
            
            dns(it) = datenum(iyear,imonth,idate,ihour,iminute,isecond);
            
            iyear  = str2double(csfile(end-23:end-20));
            imonth = str2double(csfile(end-18:end-17));
            idate  = str2double(csfile(end-15:end-14));
            ihour  = str2double(csfile(end-12:end-11));
            iminute= str2double(csfile(end-10:end-9));
            isecond= str2double(csfile(end-8:end-7));
            
            if (datenum(iyear,imonth,idate,ihour,iminute,isecond)~=dns(it))
               display('S-File Time Mismatch, check your directories');
               display('and the prefixes');
               return;
            end

            if (it==nsfiles)
               iyearz=iyear;
            end

            if (it==1)
               iyeara=iyear;
               tmp = hdf5read(tsfile,'/AGB_PY');
               agb_t = zeros([nsfiles,size(tmp,1)]);
               agb_c = zeros([nsfiles,size(tmp,1)]);
               lai_t = zeros([nsfiles,size(tmp,1)]);
               lai_c = zeros([nsfiles,size(tmp,1)]);
               scp_t = zeros([nsfiles,3]);
               scp_c = zeros([nsfiles,3]);
            end

            tmp = hdf5read(tsfile,'/AGB_PY');
            agb_t(it,:) = sum(tmp,2);
            
            tmp = hdf5read(csfile,'/AGB_PY');
            agb_c(it,:) = sum(tmp,2);
            
            tmp = hdf5read(tsfile,'/LAI_PY');
            lai_t(it,:) = sum(tmp,2);
            
            tmp = hdf5read(csfile,'/LAI_PY');
            lai_c(it,:) = sum(tmp,2);
            
            scp_t(it,1) = hdf5read(tsfile,'/FAST_SOIL_C_PY'  );
            scp_t(it,2) = hdf5read(tsfile,'/STRUCT_SOIL_C_PY');
            scp_t(it,3) = hdf5read(tsfile,'/SLOW_SOIL_C_PY'  );
            
            scp_c(it,1) = hdf5read(csfile,'/FAST_SOIL_C_PY'  );
            scp_c(it,2) = hdf5read(csfile,'/STRUCT_SOIL_C_PY');
            scp_c(it,3) = hdf5read(csfile,'/SLOW_SOIL_C_PY'  );
         end

         pftsucc_pref{is} = sprintf('%sagb_lai_pft_%s',outdir,siteid{is});
         pftsucc_img{is} = sprintf('%s.eps',pftsucc_pref{is});
         titlestr = sprintf('%s\n',site_name{is});
         plot_succession(dns,agb_t,agb_c,lai_t,lai_c,titlestr, ...
             pftsucc_pref{is},runstat{spass(is,2)+1},runstat{spass(is,3)+1},visible)


         soilcarb_pref{is} = sprintf('%ssoilcarbon_%s',outdir,siteid{is});
         soilcarb_img{is}  = sprintf('%s.eps',soilcarb_pref{is});
         titlestr = sprintf('%s\n',site_name{is});
         plot_soilcarbon(dns,scp_t,scp_c,titlestr,soilcarb_pref{is},visible)

         longterm_pref{is} = sprintf('%slongterm_%s',outdir,siteid{is});
         longterm_img{is}  = sprintf('%s.eps',longterm_pref{is});
      end % if  ( (nqfiles > 2) && (nsfiles > 2) )
   end     % (for is=1:npoi)
end     % (if nsite>0)


if (nhifr > 0)

   display(sprintf('\nHigh Frequency Output'))
   display(sprintf('Check Patch Level Mass and Energy Conservation\n'));    

   latex_htab = zeros(13,nhifr);

   latex_hname={'$\\Delta E$','$\\dot{E}_{Pcp}$','$\\dot{E}_{Rn}$', ...
                '$\\dot{E}_{\\rho}$','$\\dot{E}_P$','$\\dot{E}_{VD}$', ...
                '$\\dot{E}_{EF}$','$\\dot{E}_{RO}$','$\\Delta C$', ...
                '$\\dot{C}_{\\rho}$','$\\dot{C}_{VD}$','$\\dot{C}_{NS}$', ...
                '$\\dot{C}_{EF}$'};
   latex_hunit={'$MJ/m^2$','$MJ/m^2$','$MJ/m^2$','$MJ/m^2$','$MJ/m^2$', ...
                 '$MJ/m^2$','$MJ/m^2$','$MJ/m^2$','kgC/m^2$','kgC/m^2$', ...
                 '$kgC/m^2$','kgC/m^2$','kgC/m^2$'};

   for ih = 1:nhifr
      % We only plot simulations that have reached the end.
      if ( (hpass(ih,2) == 2) && (hpass(ih,3) == 2) )
         hshow(ih)=true;

         display(sprintf('Plot budget report for site %s,',hifrid{ih}));



         test_b_pfx = sprintf('%s/F_test_%s/test_%s_budget_state_patch_', ...
                                 test_name,hifrid{ih},hifrid{ih});
         cont_b_pfx = sprintf('%s/F_main_%s/main_%s_budget_state_patch_', ...
                                 test_name,hifrid{ih},hifrid{ih});

         display(test_b_pfx);

         id=strfind(test_b_pfx,'/');
         test_b_dir = test_b_pfx(1:id(end));
         
         id=strfind(cont_b_pfx,'/');
         cont_b_dir = cont_b_pfx(1:id(end));
         
         test_b_flist = dir(strcat(test_b_pfx,'*txt'));
         cont_b_flist = dir(strcat(cont_b_pfx,'*txt'));
         
         nbfiles     = length(test_b_flist);

         if (nbfiles ~= length(cont_b_flist))
            display(sprintf('Budget file lists are different lengths - %s',siteid{is}));
            display(['Different number of patch output, or multiple runs?']);
            return;
         elseif (nbfiles == 0)
            display('Could not find any patch files');
            return;
         else
            npatch = nbfiles;
            ndat1=0;
            for ipa=1:npatch
               tbfile = strcat(test_b_dir,test_b_flist(ipa).name);
               cbfile = strcat(cont_b_dir,cont_b_flist(ipa).name);

               % Read in the patch data for the test sim
               [ndat,cbud_t,ebud_t,wbud_t,cstor_t,estor_t,wstor_t,~] ...
                   = read_patch_budgets(tbfile,ndat1);

               % Read in the patch data for the main sim
               [~,cbud_c,ebud_c,wbud_c,cstor_c,estor_c,wstor_c,dnv] ...
                   = read_patch_budgets(cbfile,ndat);

               % First pass, zero patch arrays
               if (ipa==1)
                  cbuds_t  = zeros(ndat,6,npatch);
                  ebuds_t  = zeros(ndat,9,npatch);
                  wbuds_t  = zeros(ndat,7,npatch);
                  cstors_t = zeros(ndat  ,npatch);
                  estors_t = zeros(ndat  ,npatch);
                  wstors_t = zeros(ndat  ,npatch);
                  cbuds_c  = zeros(ndat,6,npatch);
                  ebuds_c  = zeros(ndat,9,npatch);
                  wbuds_c  = zeros(ndat,7,npatch);
                  cstors_c = zeros(ndat  ,npatch);
                  estors_c = zeros(ndat  ,npatch);
                  wstors_c = zeros(ndat  ,npatch);
               end
               
               cbuds_t (:,:,ipa) = cbud_t;
               ebuds_t (:,:,ipa) = ebud_t;
               wbuds_t (:,:,ipa) = wbud_t;
               cbuds_c (:,:,ipa) = cbud_c;
               ebuds_c (:,:,ipa) = ebud_c;
               wbuds_c (:,:,ipa) = wbud_c;
               cstors_t(:  ,ipa) = cstor_t;
               estors_t(:  ,ipa) = estor_t;
               wstors_t(:  ,ipa) = wstor_t;
               cstors_c(:  ,ipa) = cstor_c;
               estors_c(:  ,ipa) = estor_c;
               wstors_c(:  ,ipa) = wstor_c;
               
               dtfac = (dnv(2)-dnv(1))*86400.0;
               ebud_cst=1e-6*dtfac*cumsum(ebud_t,1);
               cbud_cst=1000*dtfac*cumsum(cbud_t,1);
               ebud_csc=1e-6*dtfac*cumsum(ebud_c,1);
               cbud_csc=1000*dtfac*cumsum(cbud_c,1);
               
               latex_htab(1,ih) = latex_htab(1,ih)+...
                   (ebud_cst(end,2)-ebud_csc(end,2))./npatch;
               latex_htab(2,ih) = latex_htab(2,ih)+...
                   (ebud_cst(end,3)-ebud_csc(end,3))./npatch;
               latex_htab(3,ih) = latex_htab(3,ih)+...
                   (ebud_cst(end,4)-ebud_csc(end,4))./npatch;
               latex_htab(4,ih) = latex_htab(4,ih)+...
                   (ebud_cst(end,5)-ebud_csc(end,5))./npatch;
               latex_htab(5,ih) = latex_htab(5,ih)+...
                   (ebud_cst(end,6)-ebud_csc(end,6))./npatch;
               latex_htab(6,ih) = latex_htab(6,ih)+...
                   (ebud_cst(end,7)-ebud_csc(end,7))./npatch;
               latex_htab(7,ih) = latex_htab(7,ih)+...
                   (ebud_cst(end,8)-ebud_csc(end,8))./npatch;
               latex_htab(8,ih) = latex_htab(8,ih)+...
                   (ebud_cst(end,9)-ebud_csc(end,9))./npatch;
               latex_htab(9,ih) = latex_htab(9,ih)+...
                   (cbud_cst(end,2)-cbud_csc(end,2))./npatch;
               latex_htab(10,ih)= latex_htab(10,ih)+...
                   (cbud_cst(end,3)-cbud_csc(end,3))./npatch;
               latex_htab(11,ih)= latex_htab(11,ih)+...
                   (cbud_cst(end,4)-cbud_csc(end,4))./npatch;
               latex_htab(12,ih)= latex_htab(12,ih)+...
                   (cbud_cst(end,5)-cbud_csc(end,5))./npatch;
               latex_htab(13,ih)= latex_htab(13,ih)+...
                   (cbud_cst(end,6)-cbud_csc(end,6))./npatch;

               ndat1=ndat;
            end %for ipa=1:npatch

            cbudg_outfile{ih} = ...
                sprintf('%s/cbudg_%s_%s.eps',outdir,test_name,hifrid{ih});          
            ebudg_outfile{ih} = ...
                sprintf('%s/ebudg_%s_%s.eps',outdir,test_name,hifrid{ih});
            wbudg_outfile{ih} = ...
                sprintf('%s/wbudg_%s_%s.eps',outdir,test_name,hifrid{ih});


            plot_patchbudgets(dnv,cbuds_t,ebuds_t,wbuds_t,cstors_t,estors_t,wstors_t...
                             ,cbuds_c,ebuds_c,wbuds_c,cstors_c,estors_c,wstors_c...
                             ,cbudg_outfile{ih},ebudg_outfile{ih},wbudg_outfile{ih}...
                             ,runstat{hpass(ih,2)+1},runstat{hpass(ih,3)+1},visible);
         end %  (nbfiles ~= length(cont_b_flist))
      else
         display(sprintf('Site %s is not ready or had problems.',hifrid{ih}));
      end  % if ( (hpass(ih,2) == 2) && (hpass(ih,3) == 2) )
   end % for ih = 1:nhifr
end %if (nhifr > 0)
%==========================================================================


%==========================================================================
% Validation of the gridded simulation
%==========================================================================

latex_gname = {'$AGB$','$BA$'};
latex_gunit = {'$kgC/m^2$','$cm^2/m^2$'};


if (ngrid > 0)
   latex_gtab = zeros(2,ngrid);
   display('Assessing Gridded site(s)'); 
   for ig=1:ngrid

      test_gs_pfx = sprintf('%s/F_test_%s/test_%s-Q-',test_name,gridid{ig},gridid{ig});
      cont_gs_pfx = sprintf('%s/F_main_%s/main_%s-Q-',test_name,gridid{ig},gridid{ig});

      test_gs_flist = dir(strcat(test_gs_pfx,'*h5'));
      cont_gs_flist = dir(strcat(cont_gs_pfx,'*h5'));
      id=strfind(cont_gs_pfx,'/');
      cont_gs_dir = cont_gs_pfx(1:id(end));
      
      id=strfind(test_gs_pfx,'/');
      test_gs_dir = test_gs_pfx(1:id(end));

      ngsfiles    = min([length(cont_gs_flist) length(test_gs_flist)]);
      display(sprintf('Gridded region %s.  File count: %i.',gridid{ig},ngsfiles));

      if (ngsfiles > 2)
         gshow(ig) = true;

         tsfile = strcat(test_gs_dir,test_gs_flist(ngsfiles).name);
         csfile = strcat(cont_gs_dir,cont_gs_flist(ngsfiles).name);
         
         lat_gt    = double(hdf5read(tsfile,'/LATITUDE'));
         lon_gt    = double(hdf5read(tsfile,'/LONGITUDE'));
         lairaw_gt = double(hdf5read(tsfile,'/MMEAN_LAI_PY')); %m2/m2
         agbraw_gt = double(hdf5read(tsfile,'/AGB_PY')); %kg/m2 -> kgC/m2
         npoly_gt  = length(lat_gt);

         lat_gc    = double(hdf5read(csfile,'/LATITUDE'));
         lon_gc    = double(hdf5read(csfile,'/LONGITUDE'));
         lairaw_gc = double(hdf5read(csfile,'/MMEAN_LAI_PY')); %m2/m2
         agbraw_gc = double(hdf5read(csfile,'/AGB_PY'));  %kg/m2 -> kgC/m2
         npoly_gc  = length(lat_gc);
         
         if (npoly_gt~=npoly_gc)
            display('YOU SCREWED UP_ THE DATA');
            return;
         end

         [npft,ndbh,npoly] = size(agbraw_gt);

         lai_gt = zeros(npoly,npft);
         lai_gc = zeros(npoly,npft);
         agb_gt = zeros(npoly,npft);
         agb_gc = zeros(npoly,npft);

         for ipy=1:npoly
            for ipft=1:npft
                agb_gt(ipy,ipft) = sum(agbraw_gt(ipft,:,ipy));
                agb_gc(ipy,ipft) = sum(agbraw_gc(ipft,:,ipy));
                lai_gt(ipy,ipft) = sum(lairaw_gt(ipft,:,ipy));
                lai_gc(ipy,ipft) = sum(lairaw_gc(ipft,:,ipy));
            end
         end

         % Determine which PFT's are present
         usepft = zeros(npft,1);
         for ipft=1:npft
             if(~isempty(find(agb_gt(:,ipft)>0)) || ...
                     ~isempty(find(agb_gc(:,ipft)))) %#ok<*EFIND>
                 usepft(ipft) = 1;
             end
         end

         agbmap_pref{ig} = sprintf('%sagbmap_%s',outdir,gridid{ig});
         laimap_pref{ig} = sprintf('%slaimap_%s',outdir,gridid{ig});
         agbmap_img{ig}  = sprintf('%sagbmap_%s.eps',outdir,gridid{ig});
         laimap_img{ig}  = sprintf('%slaimap_%s.eps',outdir,gridid{ig});
         
         plot_agbmaps(usepft,agb_gt,agb_gc,lon_gc,lat_gc,npoly,agbmap_pref{ig}...
                     ,runstat{gpass(ig,2)+1},runstat{gpass(ig,3)+1},visible,grid_name{ig});
         plot_laimaps(usepft,lai_gt,lai_gc,lon_gc,lat_gc,npoly,laimap_pref{ig}...
                     ,runstat{gpass(ig,2)+1},runstat{gpass(ig,3)+1},visible,grid_name{ig});

         latex_gtab(1,ig) = mean(sum(agb_gt,2)-sum(agb_gc,2));
         latex_gtab(2,ig) = mean(sum(lai_gt,2)-sum(lai_gc,2));
      end % if (ngsfiles > 2)
   end   % for ig=1:ngrid
end   % if (ngrid > 0)


%==========================================================================
% Part 4: Table Fast Values
%==========================================================================


%==========================================================================
% Generate the Report
%==========================================================================

latexgen;
