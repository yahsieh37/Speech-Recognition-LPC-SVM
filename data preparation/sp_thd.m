function [sp_out] = sp_thd(sp,thd)

    j=1;
    sp_out = 0;
    for i=1:length(sp)
        if(abs(sp(i))>thd)
            sp_out(j)=sp(i);
            j=j+1;
        end
    end
    
end

