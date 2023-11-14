%define pred_label 0
%macro colon 2

    %ifstr %1

        %ifid %2

            %2: 
                db %1, 0
                dq pred_label
            %define pred_label %2

        %else

            %error "Некорректный идентификатор"

        %endif

    %else

        %error "Значение должно быть строкой"
    
    %endif

%endmacro
