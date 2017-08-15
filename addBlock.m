function [dat_so_far] = addBlock(block_to_add, dat_so_far)

linesInBlock = size(block_to_add,1);
tmp = [];
for rowInDatSoFar = 1:size(dat_so_far,1)
    % place the new block with each row of dat_so_far (into tmp)
    tmp = [tmp; repmat(dat_so_far(rowInDatSoFar,:),[linesInBlock 1]) block_to_add];
end
dat_so_far = tmp;