function [prec,f1,recall] = precision_f1_recall(conmat)

    prec = conmat (1)/ (conmat(3)+conmat(1));
    recall = conmat (1)/ (conmat(2)+conmat(1));
    f1 = 2*prec*recall / (prec + recall);


end

