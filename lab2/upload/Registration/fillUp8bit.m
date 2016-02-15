function I_out = fillUp8bit(I_in)
% Takes an 2D image and compress or stretch the values to [0 255]
I_in = double(I_in - min(I_in(:)));
I_out = uint8(255*(I_in./max(I_in(:))));