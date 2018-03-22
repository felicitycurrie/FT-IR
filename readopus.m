function [spectra, xvalues, information, file_contents] = readopus(filename)

%
% Extracts spectra and information from Bruker OPUS files.
% Version 3.1
%
% Syntax:
%  [spectra, xvalues, information, file_contents] = readopus(filename);
%   or
%  [spectra, xvalues, information] = readopus(filename);
%   or
%  [spectra, xvalues] = readopus(filename);
%   or
%  [spectra] = readopus(filename);
%   as required
%
% Alternatively, if the filename is left blank, any of the above commands
% will ask for a file to open. 
%
%
% Function to read and output the contents of Bruker OPUS files.
%
% Input:
%       filename 
%           The name of the OPUS file as a string eg 'myfile.0'
%           (leave this out and you will be prompted for a filename)
%
% Output:
%       spectra
%           A matrix of spectra (as rows) (IMPORTANT: see Notes 1&2 below)
%       xvalues
%           Either
%           1) A matrix of x-values (as rows) that match each of the spectra
%           above (See Note 2 below)
%           2) If this is a multi-spectra file we only output 1 set of
%           x-values (See Note 2 below)
%       information
%           A matrix of cell arrays that contain detail of the spectra above, for
%           example, number of points, first and last x-values, x-data type
%           (wavenumber etc), date of acquisition... (See Note 3)
%       file_contents
%           A matrix of cells arrays which lists the full contents of the
%           file. The file is stored in blocks and this is an explanation
%           of the contents of each block. Only the 'data status
%           parameters' and 'spectrum' blocks are extracted here. This is
%           not synchronised with the spectra and so you get one
%           'file_contents' entry per file regardless of the number of
%           spectra it contains.
%
% Notes:
%       1) A single spectrum file actually contains 3 spectra - sample,
%       reference and ratio. All three are ouput here in that order. It is
%       possible that multi-spectrum files will not have this ordering and
%       may not contain reference or ratioed spectra at all. 
%       Care should be taken here and we can modify this function if required. 
%
%       2) Where we have a multi-spectral file (perhaps from a 96-well
%       microarray analysis) we output all the spectra as in 1 above, but
%       only output 1 set of x-data since they are all the same. 
%
%       3) The 'information' output is a matrix of cell arrays. These can
%       be accessed using cell notation which involves braces { } rather
%       than round or square brackets ( ) [ ]. For example, to see the
%       information relating to the second spectrum enter info{2,:} at the command
%       prompt. (This assumes that 'info' is the third return value of the
%       function.) Where there is an entry displayed as [1x30 char] use the
%       following syntax: info{2,1}{2,3} to get the third column of the
%       second row of the second cell array in column 1 (read backwards).
%
%       4) This function was written to match the Bruker OPUS file format
%       specification dated 23.1.92 which was provided under a
%       confidentiality agreement. It should not be passed to others who
%       have not signed such an agreement. 
%
%       5) The 3d functionality relies on the data storage parameters
%       coming after the spectrum block. In a single analysis, this comes
%       before the spectrum block. The file format indicates that there is
%       a flag, but doesn't specify where it is!
%
%
% Version 3.1 (Alex Henderson Sep 2010)
%   Changes from Version 3.0
%       1) Fixed bug which caused a crash in R2009a
%
% Version 3.0 (Alex Henderson May 2009)
%   Changes from Version 2.0
%       1) Incorporated all functions into one super function to prevent
%          source files becoming separated from the collection. 
%       2) Added feature to prompt for a filename if not provided. 
%       3) The file now opens in Windows mode (little endian). 
%       4) Updated the help info to reflect these changes.
%
% Version 2.0 (Alex Henderson Jan 2008)
%   Changes from Version 1
%       1) Added 3d functionality. This changes the number of x-value sets.
%       2) We now need the opus_3d_data_internal.m file for handling the 3d
%       datasets.
%       3) Updated the help info above.
%
% Version 1 (Alex Henderson, February 2007)
%

%filename = 'alex1.0';   % for debugging purposes only
%filename = 'caseinp200dryingb.0'; % for debugging purposes only
spectra = [];
xvalues = [];
information = cell(1,1);
file_contents = cell(1,1);

if (exist('filename', 'var') == 0)
    [filename] = getfilename(); % this function is below
end

[spectra, xvalues, information, file_contents] = opus_spectra(filename, spectra, xvalues, information, file_contents);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [spectra, xvalues, information, file_contents] = opus_spectra(filename, spectra, xvalues, information, file_contents)

[fid, message] = fopen(filename, 'r', 'l');
if(fid == -1) 
    error(message); 
end;

% header block
Magic_number = fread(fid, 1, '*int32');
if(Magic_number ~= -16905718)
    % magic number should be 0x0A0AFEFE, but this is easier
    message = 'Not a valid OPUS file.';
    error(message);
end;

program_version_number = fread(fid, 1, '*float64');
pointer_to_first_directory_in_bytes = fread(fid, 1, '*int32');
max_size_of_directory_in_blocks = fread(fid, 1, '*int32');
current_size_of_directory_in_blocks = fread(fid, 1, '*int32');

% directory blocks
% jump to start of directory block
% this might be after the header or at the end of the file
status = fseek(fid, double(pointer_to_first_directory_in_bytes), 'bof');
if(status == -1)
    message = ferror(fid, 'clear');
    error(message); 
end;

% read the directory blocks into a matrix where each row is a directory
% entry
block_list = [];
finished=0;
while (~finished)    
    Block_type = fread(fid, 1, '*uint32');
    Length_in_32BitWrds = fread(fid, 1, 'int32');
    Pointer_in_bytes = fread(fid, 1, 'int32');
    length_in_bytes = Length_in_32BitWrds * 4;
    if (Pointer_in_bytes == 0)
        finished = 1;
    else
        block_list = vertcat(block_list,[Block_type, Length_in_32BitWrds, length_in_bytes, Pointer_in_bytes]);
    end
end

number_of_blocks = size(block_list,1);
block_types = cell(number_of_blocks,6);
data_status_parameters_counter = 1;
data_available = 0;

for current_block = 1:number_of_blocks

    clear block_info;
    block_info = cell(1,1);
    entry = 1;
    data_status_parameter = 0;
    spectrum_data = 0;

    % bits 0-1
    block_type = block_list(current_block,1);
    masked = bitand(block_type, 3);
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'real part of complex data';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 2
            info = 'imaginary part of complex data';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 3
            info = 'amplitude data';
            block_info{entry,1} = info;
            entry = entry + 1;
        otherwise
            error('undefined directory type');
    end    

    % bits 2-3
    block_type = block_list(current_block,1);
    shifted = bitshift(block_type, -2);
    masked = bitand(shifted, 3);
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'sample data';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 2
            info = 'reference data';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 3
            info = 'ratioed data';
            block_info{entry,1} = info;
            entry = entry + 1;
        otherwise
            error('undefined directory type');
    end    

    % bits 4-9
    block_type = block_list(current_block,1);
    shifted = bitshift(block_type, -4);
    masked = bitand(shifted, 63); % 77 octal
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'data status Parameter';
            block_info{entry,1} = info;
            entry = entry + 1;
            data_status_parameter = 1;
        case 2
            info = 'Instrument status parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 3
            info = 'standard acquisition parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 4
            info = 'FT-Parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 5
            info = 'Plot- and display parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 6
            info = 'Processing parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 7
            info = 'GC-parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 8
            info = 'Library search parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 9
            info = 'Communication parameters';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 10
            info = 'Sample origin parameter';
            block_info{entry,1} = info;
            entry = entry + 1;
        otherwise
            info = 'Sample origin parameter';
            block_info{entry,1} = info;
            entry = entry + 1;
    end    

    % bits 10-16
    block_type = block_list(current_block,1);
    shifted = bitshift(block_type, -10);
    masked = bitand(shifted, 127); % 177 octal
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'spectrum, undefined Y-units';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 2
            info = 'interferogram';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 3
            info = 'phase spectrum';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 4
            info = 'absorbance spectrum (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 5
            info = 'transmittance spectrum (peaks down)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 6
            info = 'kubelka-munck spectrum (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 7
            info = 'trace (intensity over time) (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 8
            info = 'gc file, series of interferograms';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 9
            info = 'gc file, series of spectra';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 10
            info = 'raman spectrum (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 11
            info = 'emission spectrum (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 12
            info = 'reflectance spectrum (peaks down)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 13
            info = 'directory block';
            block_info{entry,1} = char(info);
            entry = entry + 1;
        case 14
            info = 'power spectrum (from phase calculation)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 15
            info = 'log reflectance (like absorbance) (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 16
            info = 'ATR-spectrum (peaks down)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 17
            info = 'photoacoustic spectrum (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 18
            info = 'result of arithmetics, looks like TR (peaks down)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        case 19
            info = 'result of arithmetics, looks like AB (peaks up)';
            block_info{entry,1} = info;
            entry = entry + 1;
            spectrum_data = 1;
        otherwise
            info = 'further data types to be added';
            block_info{entry,1} = info;
            entry = entry + 1;
    end    

    % bits 17-18
    block_type = block_list(current_block,1);
    shifted = bitshift(block_type, -17);
    masked = bitand(shifted, 3); 
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'first derivative';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 2
            info = 'second derivative';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 3
            info = 'n-th derivative';
            block_info{entry,1} = info;
            entry = entry + 1;
        otherwise
            error('undefined directory type');
    end    

    % bits 19->
    block_type = block_list(current_block,1);
    shifted = bitshift(block_type, -19);
    masked = bitand(shifted, 127); % 177 octal
    
    switch masked
        case 0
            info = 'undefined';
        case 1
            info = 'compound Information';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 2
            info = 'peak table';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 3
            info = 'molecular structure';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 4
            info = 'macro';
            block_info{entry,1} = info;
            entry = entry + 1;
        case 5
            info = 'log of all actions which change data';
            block_info{entry,1} = info;
            entry = entry + 1;
        otherwise
            info = 'extended data type (unknown)';
            block_info{entry,1} = info;
            entry = entry + 1;
    end    

    
    file_contents{current_block,1} = block_info;
    
    
    if(data_status_parameter == 1)
        block_offset = block_list(current_block,4);
        this_parameter_set = opus_parameters_internal(filename, block_offset, 'data status Parameter');
        for parameter = 1:size(this_parameter_set,1)
            if strcmp(this_parameter_set{parameter,1}, 'DPF')
                number_format_type_id = this_parameter_set{parameter,2};
                if number_format_type_id == 1
                    number_format_type = 'REAL32';
                end
                if number_format_type_id == 2
                    number_format_type = 'INT32';
                end
            end
            if strcmp(this_parameter_set{parameter,1}, 'NPT')
                number_of_points = this_parameter_set{parameter,2};
            end
            if strcmp(this_parameter_set{parameter,1}, 'FXV')
                x_start = this_parameter_set{parameter,2};
            end
            if strcmp(this_parameter_set{parameter,1}, 'LXV')
                x_end = this_parameter_set{parameter,2};
            end
        end
        information{data_status_parameters_counter,1}= this_parameter_set;
        data_status_parameters_counter = data_status_parameters_counter + 1;
        data_available = 1;
        continue;
    end

    if((data_available == 0) && (spectrum_data == 1))   % possible 3d block
        block_offset = block_list(current_block,4);
        [this_spectrum, x_start, x_end, number_of_points] = opus_3d_data_internal(filename, block_offset);
        spectra = vertcat(spectra, this_spectrum);
        data_available = 0;
        
        % handle x data
        x_step = (x_end - x_start)/(number_of_points - 1);
        xvals = x_start:x_step:x_end;
        xvalues = vertcat(xvalues, xvals);
    end

    if((data_available == 1) && (spectrum_data == 1))
        block_offset = block_list(current_block,4);
        this_spectrum = opus_data_internal(filename, block_offset, block_size, number_of_points, number_format_type);
        spectra = vertcat(spectra, this_spectrum);
        data_available = 0;
        
        % handle x data
        x_step = (x_end - x_start)/(number_of_points - 1);
        xvals = x_start:x_step:x_end;
        xvalues = vertcat(xvalues, xvals);
    end
    
end
   
fclose(fid);
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [parameters] = opus_parameters_internal(filename, offset, blocktype)

%
% Part of a suite of functions to extract spectra and information from 
% Brucker OPUS files.
%
% This function should not be run independently. It requires information
% (the file offset and blocktype) from opus_spectra.m
%
% Note: This function was written to match the Bruker OPUS file format
%       specification dated 23.1.92 which was provided under a
%       confidentiality agreement. It should not be passed to others who
%       have not signed such an agreement. 
%
%       This function requires four other functions to be present in the
%       current path: opus_spectra.m, opus_data_internal.m, 
%       opus_3d_data_internal.m and opus_codes_internal.m. 
%       These functions cannot be operated independently since they 
%       require file offsets etc. 
%
% Syntax: 
%  [parameters] = opus_parameters_internal(filename, offset, blocktype);
%
% Version 2.0 
%   Changes from Version 1
%       1) Updated the help info above. Nothing else changed in this file.
%
%   Alex Henderson, February 2007
%

%filename = 'alex1.0';   % for debugging purposes only
%filename = 'caseinp200dryingb.0';
%offset = 24;
%type = 'parameter_type';

%pack;   % Let's give ourselves some elbow room!

offset = double(offset);

[fid, message] = fopen(filename);
if(fid == -1) 
    error(message); 
end;

% header block
Magic_number = fread(fid, 1, '*int32');
if(Magic_number ~= -16905718)
    % magic number should be 0x0A0AFEFE, but this is easier
    message = 'Not a valid OPUS file.';
    error(message);
end;

% jump to the block
status = fseek(fid, offset, 'bof');
if(status == -1)
    message = ferror(fid, 'clear');
    error(message); 
end

% read parameter block values
parameters = cell(1,3);
parameters{1,1} = 'Block type';
parameters{1,2} = sscanf(blocktype, '%s');
counter = 2;
finished = 0;
while (~finished)    
    Parameter_name = fread(fid, 4, '*char');    
    Parameter_name = Parameter_name';
    Parameter_name = sscanf(Parameter_name, '%s');
    if (strcmp(Parameter_name, 'END'))
        finished = 1;
        fread(fid, 5, '*char'); % rest of previous END block        
    else
        Parameter_type = fread(fid, 1, '*int16');
        Parameter_Reserved_space = fread(fid, 1, '*int16'); % amount of space * 2 bytes
            switch Parameter_type
                case 0
                    % Parameter_type = 'INT32';
                    Parameter_value = fread(fid, 1, 'int32');
%                    Parameter_value = num2str(Parameter_value);
                case 1
                    % Parameter_type = 'REAL64';
                    Parameter_value = fread(fid, 1, 'double');
%                    Parameter_value = num2str(Parameter_value);
                case 2
                    % Parameter_type = 'STRING';
                    temp = fread(fid, 2*double(Parameter_Reserved_space), '*char');
                    temp = temp';
                    Parameter_value = sscanf(temp, '%s');
                case 3
                    % Parameter_type = 'ENUM';
                    temp = fread(fid, 2*double(Parameter_Reserved_space), '*char');
                    temp = temp';
                    Parameter_value = sscanf(temp, '%s');
                case 4
                    % Parameter_type = 'SENUM';
                    temp = fread(fid, 2*double(Parameter_Reserved_space), '*char');
                    temp = temp';
                    Parameter_value = sscanf(temp, '%s');
                otherwise
                    Parameter_value = 'unknown parameter value';
            end

        parameters{counter,1} = Parameter_name;
        parameters{counter,2} = Parameter_value;
        parameters{counter,3} = opus_codes_internal(Parameter_name);
        
        counter = counter + 1;
    end
end

fclose(fid);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [output, x_start, x_end, number_of_points] = opus_3d_data_internal(filename, offset)

%
% Part of a suite of functions to extract spectra and information from 
% Bruker OPUS files.
%
% This function should not be run independently. It requires information
% (the file offset) from opus_spectra.m
%
% Note: This function was written to match the Bruker OPUS file format
%       specification dated 23.1.92 which was provided under a
%       confidentiality agreement. It should not be passed to others who
%       have not signed such an agreement. 
%
%       This function requires four other functions to be present in the
%       current path: opus_spectra.m opus_parameters_internal.m, 
%       opus_data_internal and opus_codes_internal.m. These functions 
%       cannot be operated independently since they require file offsets etc. 
%
% Syntax: 
% [output, x_start, x_end, number_of_points] = opus_3d_data_internal(filename, offset)
%
% Version 3.0 
%   Changes from Version 2
%       1) Preallocating memory for output speeds file reads by x50. No
%       change to operation of the code.
%   Changes from Version 1
%       1) This file didn't exist in version 1.
%
%   (c) Alex Henderson, February 2007, Jan 2008
%

%filename = 'alex1.0';   % for debugging purposes only
%filename = 'caseinp200dryingb.0';
%offset = 24;

[fid, message] = fopen(filename);
if(fid == -1) 
    error(message); 
end;

% header block
Magic_number = fread(fid, 1, '*int32');
if(Magic_number ~= -16905718)
    % magic number should be 0x0A0AFEFE, but this is easier
    message = 'Not a valid OPUS file.';
    error(message);
end;

status = fseek(fid, double(offset), 'bof');
if(status == -1)
    message = ferror(fid, 'clear');
    error(message); 
end

output = [];

% Structure of 3D block
% The 3D block structure is as follows; 
%   POST_HEADER (x1)
%   POST_ENTRY  (x1)
%       repeats of pairs of;
%           Spectrum block (size in header - lBlockSize)
%           Data block (DATA_BLOCK)  
%           possible string info
%       until end
%
% size of Data block and string info given by lInfoSize in header


% block header - struct POST_HEADER
% lVersion = fread(fid, 1, 'float32'); % file format version number ( actually 0 )
% lStoredBlks = fread(fid, 1, 'float32'); % total number of saved blocks
% lBlksOffset = fread(fid, 1, 'float32'); % offset of first block in file (in bytes)
% lBlockSize = fread(fid, 1, 'float32'); % size of a data block in bytes (spectrum etc)
% lInfoSize = fread(fid, 1, 'float32'); % size of info stored after each block in bytes
% lNumEntries = fread(fid, 1, 'float32'); % number of POST_ENTRY struct. in store table

lVersion = fread(fid, 1, 'int32'); % file format version number ( actually 0 )
lStoredBlks = fread(fid, 1, 'int32'); % total number of saved blocks
lBlksOffset = fread(fid, 1, 'int32'); % offset of first block in file (in bytes)
lBlockSize = fread(fid, 1, 'int32'); % size of a data block in bytes (spectrum etc)
lInfoSize = fread(fid, 1, 'int32'); % size of info stored after each block in bytes
lNumEntries = fread(fid, 1, 'int32'); % number of POST_ENTRY struct. in store table

% store table - struct POST_ENTRY
% list of spectral entry ranges (we can skip spectra)
% there are lNumEntries x POST_ENTRY in the block

store_table = [1,2];
run_numbers = zeros(lStoredBlks,1);
for n = 1:lNumEntries
    lTStartRun = fread(fid, 1, 'int32'); % run # of first block
    lTEndRun = fread(fid, 1, 'int32'); % run # of last block
    store_table = vertcat(store_table, [lTStartRun,lTEndRun]);
    for run_number = lTStartRun:lTEndRun
        run_numbers(run_number,1) = 1;  % there's got to be a better way!
    end
end
% run_numbers is true if we want to extract the particular entry

% jump to the start of the data
status = fseek(fid, double(lBlksOffset + offset), 'bof');
if(status == -1)
    message = ferror(fid, 'clear');
    error(message); 
end

output = zeros(lStoredBlks, (lBlockSize/4));

for entry = 1:lStoredBlks

    [spectrum, count] = fread(fid, lBlockSize/4, 'float'); 
    if  (count ~= (lBlockSize/4))
        error('didn''t read in the correct number of values');
    end       

    output(entry,:) = spectrum';

    % DATA_BLOCK stored after each spectrum
    nss = fread(fid, 1, 'int32'); % actual no of scans
    nsr = fread(fid, 1, 'int32'); % actual no of scans reference
    run = fread(fid, 1, 'int32'); % actual no of runs
    npt = fread(fid, 1, 'int32'); % number of points
    lNoGoodFW = fread(fid, 1, 'int32'); % number of good forward scans
    lNoGoodBW = fread(fid, 1, 'int32'); % number of good backward scans
    lNoBadFW = fread(fid, 1, 'int32'); % number of bad forward scans
    lNoBadBW = fread(fid, 1, 'int32'); % number of bad backward scans
    hfl = fread(fid, 1, 'double'); % high folding limit
    lfl = fread(fid, 1, 'double'); % low folding limit
    hffl = fread(fid, 1, 'double'); % high folding limit after filtering
    lffl = fread(fid, 1, 'double'); % low folding limit after filtering
    lFilterSize = fread(fid, 1, 'int32'); % Number of filter coef.
    lFilterType = fread(fid, 1, 'int32'); % Type of filter
    ffp = fread(fid, 1, 'double'); % freq of 1st point
    flp = fread(fid, 1, 'double'); % freq of last point
    min = fread(fid, 1, 'double'); % minimum of array
    max = fread(fid, 1, 'double'); % maximum of array
    scf = fread(fid, 1, 'double'); % scaling factor
    pka_fw = fread(fid, 1, 'double'); % peak amplitude forward part
    pka_bw = fread(fid, 1, 'double'); % peak amplitude bw part
    pkl_fw = fread(fid, 1, 'int32'); % peak location forw part
    pkl_bw = fread(fid, 1, 'int32'); % peak loc bw part
    start_time = fread(fid, 1, 'double'); % in sec
    end_time = fread(fid, 1, 'double'); % in sec

    sizeof_DATA_BLOCK = 152; % above
    sizeof_following_text = lInfoSize - sizeof_DATA_BLOCK;
    follow_on_text = [];
    if(sizeof_following_text > 0)
        follow_on_text =  fread(fid, sizeof_following_text, 'char');
    end
    
    x_start = ffp;
    x_end = flp;
    number_of_points = npt;
end

fclose(fid);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [output] = opus_data_internal(filename, offset, size, points, type)

%
% Part of a suite of functions to extract spectra and information from 
% Bruker OPUS files.
%
% This function should not be run independently. It requires information
% (the file offset and number of data points etc.) from opus_spectra.m
%
% Note: This function was written to match the Bruker OPUS file format
%       specification dated 23.1.92 which was provided under a
%       confidentiality agreement. It should not be passed to others who
%       have not signed such an agreement. 
%
%       This function requires four other functions to be present in the
%       current path: opus_spectra.m opus_parameters_internal.m, 
%       opus_3d_data_internal and opus_codes_internal.m. These functions 
%       cannot be operated independently since they require file offsets etc. 
%
% Syntax: 
% [output] = opus_data_internal(filename, offset, size, type);
%
% Version 2.0 
%   Changes from Version 1
%       1) Updated the help info above. Nothing else changed in this file.
%
%   Alex Henderson, February 2007
%

%filename = 'alex1.0';   % for debugging purposes only
%filename = 'caseinp200dryingb.0';
%offset = 24;
%size = 50;
%type = 'int32';

%pack;   % Let's give ourselves some elbow room!

[fid, message] = fopen(filename);
if(fid == -1) 
    error(message); 
end;

% header block
Magic_number = fread(fid, 1, '*int32');
if(Magic_number ~= -16905718)
    % magic number should be 0x0A0AFEFE, but this is easier
    message = 'Not a valid OPUS file.';
    error(message);
end;

status = fseek(fid, double(offset), 'bof');
if(status == -1)
    message = ferror(fid, 'clear');
    error(message); 
end

output = [];
number_of_spectra = double(size)/double(points);

for n = 1:number_of_spectra
    
    switch type
        case 'INT16'
            [spectrum, count] = fread(fid, points, 'int16');
            if  (count ~= size)
                error('didn''t read in the correct number of values');
            end       
        case 'INT32'
            [spectrum, count] = fread(fid, points, 'int32');
            if  (count ~= size)
                error('didn''t read in the correct number of values');
            end       
        case 'REAL32'
            [spectrum, count] = fread(fid, points, 'float');
            if  (count ~= size)
                error('didn''t read in the correct number of values');
            end       
        case 'REAL64'
            [spectrum, count] = fread(fid, points, 'double');
            if  (count ~= size)
                error('didn''t read in the correct number of values');
            end       
        otherwise
            error('undefined data type');
    end

    output = vertcat(output, spectrum');
    
end


fclose(fid);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [detail] = opus_codes_internal(code)

%
% Part of a suite of functions to extract spectra and information from 
% Brucker OPUS files.
%
% This function should not be run independently. It requires information
% (the code) from opus_spectra.m
%
% Note: This function was written to match the Bruker OPUS file format
%       specification dated 23.1.92 which was provided under a
%       confidentiality agreement. It should not be passed to others who
%       have not signed such an agreement. 
%
%       This function requires four other functions to be present in the
%       current path: opus_spectra.m, opus_data_internal.m, 
%       opus_3d_data_internal.m and opus_parameters_internal.m. 
%       These functions cannot be operated independently since they 
%       require file offsets etc. 
%
% Syntax: 
%  [detail] = opus_codes_internal(code);
%
% Version 2.0 
%   Changes from Version 1
%       1) Updated the help info above. Nothing else changed in this file.
%
%   Alex Henderson, February 2007
%



switch code

% Data status block(s) (DBTDSTAT)    
    case 'DPF'; detail = 'data point format (1=REAL32, 2=INT32)';
    case 'NPT'; detail = 'number of data points';
    case 'FXV'; detail = '1st X value';
    case 'LXV'; detail = 'last X value';
    case 'CSF'; detail = 'common factor for all Y-values';
    case 'MXY'; detail = 'maximum Y value';
    case 'MNY'; detail = 'minimum Y value';
    case 'DXU'; detail = 'data x-units (WN=wavenumber cm-1, MI=micron, LGW=log wavenumber, MIN=minutes, PNT=points)';
    case 'DYU'; detail = 'data y-units (SC=single channel, TR=transmission, AB=asorbance, KM=Kubelka-Munk, LA=-log(AB), DR=diffuse reflectance)';
    case 'DER'; detail = 'derivative (0,1,2,..)';
    case 'DAT'; detail = 'Date of measurement';
    case 'TIM'; detail = 'Time of measurement';
    case 'XTX'; detail = 'Text describing the X-axis units, optional';
    case 'YTX'; detail = 'Text describing the Y-axis units, optional';
    case 'END'; detail = 'Terminator';
    case 'DPF'; detail = 'Data type: 1 = REAL32, 2= INT32';

% Sample Acquisition parameter block (DBTAQPAR)
% This contains all input parameters necessary to define the measurement like 
% (not complete, full list see file OPUSOOOO.SRC):        
    case 'ITF'; detail = 'Interface type';
    case 'SIM'; detail = 'Simulation mode';
    case 'APT'; detail = 'Aperture setting';
    case 'AQM'; detail = 'Aquisition mode';
    case 'BMS'; detail = 'Beamsplitter setting';
    case 'COR'; detail = 'Correlation test mode';
    case 'DLY'; detail = 'Delay before mesurement';
    case 'DTC'; detail = 'Detector setting';
    case 'GSG'; detail = 'Gain switch gain';
    case 'GSW'; detail = 'Gain switch window';
    case 'HFW'; detail = 'High frequency limit';
    case 'HPF'; detail = 'High pass filter';
    case 'LFW'; detail = 'Low frequency limit';
    case 'LPF'; detail = 'Low pass filter';
    case 'LWN'; detail = 'Laser wavenumber';
    case 'NSS'; detail = 'Number of sample scans';
    case 'OPF'; detail = 'optical filter setting';
    case 'PGN'; detail = 'Programmed gain (ifs120)';
    case 'RES'; detail = 'Resolution';
    case 'RLP'; detail = 'Raman Laser Power';
    case 'RLW'; detail = 'Raman Laser Wavelength';
    case 'SCH'; detail = 'Sample measurement channel';
    case 'SGN'; detail = 'Main amplifier gain, sample';
    case 'SNR'; detail = 'Wheel position, sample measurement';
    case 'SRC'; detail = 'Source setting';
    case 'VEL'; detail = 'scanner velocity';

% Sample instrument status block (DBTINSTR)
% This block contains information about the instrument status during the
% measurement. Such informations are (not complete, full list see file
% OPUSOOOO.SRC)
    case 'LFL'; detail = 'Low folding limit';
    case 'HFL'; detail = 'High folding limit';
    case 'ASG'; detail = 'Actual signal gain';
    case 'ALF'; detail = 'Actual low-pass filter';
    case 'AHF'; detail = 'Actual high-pass filter';
    case 'ASS'; detail = 'Actual number of sample scans';
    case 'RSN'; detail = 'Running sample number';
    case 'PKA'; detail = 'Peak amplitude';
    case 'PKL'; detail = 'Peak location';
    case 'ssm'; detail = 'Sample spacing multiplicator';
    case 'SSP'; detail = 'Sample spacing divisor';
    case 'INS'; detail = 'Instrument type';
        
% Sample origin info block (DBTORGPAR)        
    case 'SNM'; detail = 'Sample name';
    case 'SFM'; detail = 'Sample form';
    case 'CNM'; detail = 'Chemist name';
    case 'HIS'; detail = 'History of last operations leading to this file';
        
% Sample FT-parameter block (DBTFTPAR) 
% not complete, full list see file OPUSOOOO.SRC
    case 'APF'; detail = 'Apodization function';
    case 'HFQ'; detail = 'High frequency cutoff';
    case 'LFQ'; detail = 'Low frequency cutoff';
    case 'PHZ'; detail = 'Phase correction mode';
    case 'PIP'; detail = 'Igram points for phase calc.';
    case 'PTS'; detail = 'Phase transform size';
    case 'SPZ'; detail = 'Stored phase mode';
    case 'ZFF'; detail = 'Zero filling factor';

    otherwise 
        detail = 'unknown';
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [filename] = getfilename()

%
%   Usage: [filename] = getfilename();
%
%   Collects a filename from the user.
%   'filename' is a char array
%
%   (c) Apr 2008, Alex Henderson
%

filetypes = {   '*.0',  'Brucker Opus Files (*.0)'; ...
                '*.*',    'All Files (*.*)'};

[filename, pathname] = uigetfile(filetypes, 'Select file...', 'MultiSelect', 'off');
filename = char([pathname filename]);
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
