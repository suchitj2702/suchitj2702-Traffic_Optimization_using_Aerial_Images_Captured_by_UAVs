v1 = 'dataset_vids/vid1.mp4';
v2 = 'dataset_vids/vid2.mp4';
v4 = 'dataset_vids/vid4.mp4';
v5 = 'dataset_vids/vid5.mp4';

vR1 = VideoReader(v1);
vR2 = VideoReader(v2);
vR4 = VideoReader(v4);
vR5 = VideoReader(v5);

i = 1;
src = 1;
dest = 4;
while(i ~= 10800)
    if mod(i, 300) == 0
        I1 = vid2img(vR1, i);
        I2 = vid2img(vR2, i);
        I4 = vid2img(vR4, i);
        I5 = vid2img(vR5, i);
        disp(i)
        tic;
        weights = weight_comp(graph, I1, I2, I4, I5);
        fprintf('Took %d mins to compute weights\n', round(toc/60, 2))
        tic;
        %algo starts....
        s1 = [2 1 3 2 6 1 5 2 4 3 5 6 4 5];
        t1 = [1 2 2 3 1 6 2 5 3 4 6 5 5 4];
        names = {'A' 'B' 'C' 'D' 'E' 'F'};
        widths = [7, 7, 5, 5, 4, 4, 5, 5, 6, 6, 4.5, 4.5, 3,3];
        lengths = [500, 500, 600, 600, 200, 200, 650, 650,410, 410, 150, 150, 100, 100];
        new_map = [2 6 1 4 8 3 10 1 13 7 14 11 5 12];
        G = make_graph(s1, t1, weights, names);
        pths = path_between_nodes(G, src, dest);

        path_final = optimal_path(pths, G, new_map, lengths, widths, weights);

        fprintf('Took %d mins to compute the path\n', round(toc/60, 2))
    end
    i = i + 1;
end

function graph = make_graph(s1, t1, weights, names)
graph = digraph(s1, t1, weights, names);
end

function paths = path_between_nodes(graph, source, destination)
A = adjacency(graph);
paths = pathbetweennodes(A,source,destination);
end

function path = optimal_path(pths, G, new_map, lengths, widths, weights)

curr_length = [];
curr_width = [];
pth_final = mat2cell([], 0, 0);
distance = [];
count = 1;

for i = 1:length(pths)
    curr = pths{i};
    
    
    for j = 1:length(curr) - 1
        index = findedge(G, curr(1, j), curr(1, j+1));
        index_final = new_map(1,index);
        
        %idxOut = findedge(G,s,t) returns the numeric edge indices, idxOut, for the edges specified by the source and target node pairs s and t%
        curr_length = [curr_length lengths(index_final)];
        curr_width = [curr_width widths(index_final)];
    end
    
    min_width = min(curr_width, [], 'omitnan');
    sum_distance = sum(curr_length, 'omitnan');
    
    if min_width > 2
        
        pth_final(count) = mat2cell(curr, size(curr,1), size(curr,2));
        count = count + 1;
        distance = [distance sum_distance];
        
        
    else
        continue;
    end
    
end

metric = [];
for i = 1:length(pth_final)
    curr_path = pth_final{i};
    
    flow = [];
    
    for j = 1:length(curr_path)-1
        index = findedge(G, curr_path(1, j), curr_path(1, j+1));
        index_final = new_map(1, index);
        flow = [flow (lengths(index_final)*widths(index_final)/7.77) - (weights(index_final))];
        
    end
    
    metric = [metric ((min(flow, [], 'omitnan'))/ distance(1, i))];
    
end

max = 0;
max_index = 0;

%Finding max metric and it's index
for k=1:length(metric)
    temp = metric(1,k);
    if temp > max
        max = temp;
        max_index = k;
    else
        continue
    end
end  
path = pth_final{max_index};
disp(path);
end