function [output] = relative_freq(hshold_y)
    
% fix this, it should be pdf in respect to its MH severity (fix in paper
% too

    den = sum (hshold_y{1}+hshold_y{2}+hshold_y{3}+hshold_y{4});
    
    

    for i = 1:4
        
        hold {i}= hshold_y{i}./den;

    end
    
    
    output = hold;
        
end

