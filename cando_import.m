function data = cando_import(file,type)
    fid = fopen(file);

    tline = fgetl(fid);
    IDE_counter = 0;
    value = [];

    days = [0,10,16,23]; 

    %all_IDE_results = zeros(256,50,71);
    all_IDE_results = zeros(257,36,100);
    file2 = load('frequencies.mat');
    freq = fliplr(file2.file');

    %while ischar(tline)
    if type == 1
        for x=1:257
            %disp(tline)
            line = sscanf(tline,'%s');
            values = strsplit(line,'[');
            result_num = size(values,2)-1;

            IDE_counter = IDE_counter + 1;
            

            for y = 1:result_num
                result(y) = values(y+1);
                result{y} = strrep(result{y},']"','');
                result = strsplit(result{y},',');
                result = result(1:end-1);
                if size(result,2) == 71
                    IDE_counter;
                end
                for z = 1:size(result,2)
                    all_IDE_results(IDE_counter,z,y) = str2double(result{z});
                end
            end

            %string_value = 
            tline = fgetl(fid);
        end
        all_IDE_results = all_IDE_results(2:end,:,:);
    else
        temp1 = csvread(file,1,1);
        temp2 = temp1;
        temp1(temp1==0) = NaN;
        temp2(:,2:end) = temp1(:,2:end);
        
        
        all_IDE_results = temp2;
    end
    fclose(fid);
    data = all_IDE_results;
end