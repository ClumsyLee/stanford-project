function [ct_errors_bar, pet_errors_bar] = draw_bars(names, ids)
    base_url = 'http://www.insight-journal.org/rire/view_result.php?methodid=';
    kinds = length(names);

    ct_errors_bar = zeros(kinds, 2);
    pet_errors_bar = zeros(kinds, 2);
    for kind = 1:kinds
        data = getDataFromWeb([base_url, int2str(ids(kind))]);
        pairs = length(data);

        ct_errors = [];
        pet_errors = [];

        for pair = 1:pairs
            prefix = data(pair).modality(1:3);
            errors = data(pair).numbers;
            errors = errors(~isnan(errors));  % Remove NAN.

            switch prefix
            case 'PET'
                pet_errors = [pet_errors; errors];
            case 'CT-'
                ct_errors = [ct_errors; errors];
            otherwise
                error(['Unknown prefix: ', prefix]);
            end
        end

        ct_errors_bar(kind, 1) = quantile(ct_errors, 0.5);
        ct_errors_bar(kind, 2) = quantile(ct_errors, 0.9);
        pet_errors_bar(kind, 1) = quantile(pet_errors, 0.5);
        pet_errors_bar(kind, 2) = quantile(pet_errors, 0.9);
    end

    figure
    bar(ct_errors_bar);
    legend('0.5 quantile errors', '0.9 quantile errors');
    set(gca, 'XTickLabel', names);
    ylabel 'errors (mm)'
    ylim([0 40]);
    title 'CT-MR Registration'

    figure
    bar(pet_errors_bar);
    legend('0.5 quantile errors', '0.9 quantile errors');
    set(gca, 'XTickLabel', names);
    ylabel 'errors (mm)'
    ylim([0 40]);
    title 'PET-MR Registration'
end
