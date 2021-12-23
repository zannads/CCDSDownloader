m_f = ~fh.list2download{:, "Dwn_e"};
disp( ['Missing files: ', num2str( length(m_f(m_f) ) ) ] );

avStats = ~isnat(fh.list2download{:, "Dwn_sT"}) & ~isnat(fh.list2download{:, "Dwn_eT"});
N = sum( double(avStats) );

elapsT = fh.list2download{avStats, "Dwn_eT"}-fh.list2download{avStats, "Dwn_sT"};
m_epT = mean( elapsT );

if ~exist( 'f', 'var') | ~isvalid(f)
    f = figure;
end
figure(f);
hold off;
plot( 1:N, elapsT' );
grid on;
hold on;
plot( [1, N], [m_epT, m_epT], '--r' );
legend( 'Actual', 'Mean' );
title( 'Elapsed time for download' );

disp( strcat("Predicted end time: ", string( datetime+ length(m_f(m_f) )*m_epT/fd.max_download ), ...
    " - ", string( datetime+ length(m_f(m_f) )*m_epT ) ) );

clear m_f avStats N elapsT m_epT