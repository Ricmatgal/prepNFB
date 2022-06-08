function [image_out] = smooth_edges(image_in, mask_in, kernelSize, blur_radius)
    
%     kernelSize = 3;
%     blur_radius =7;
    
    % extend the mask by smooth radius 
    edgeMask_dilated    = imdilate(mask_in, strel('disk', blur_radius));
    mask_pixels         = find(edgeMask_dilated==1);
    
    % smooth the whole image
    smoothed_image = imgaussfilt(image_in,kernelSize);
    
    % replace pixel values within extended mask of original image with those
    % of the smoothed values.
    image_out = image_in;
    
    image_out(mask_pixels) = smoothed_image(mask_pixels);
 
end



