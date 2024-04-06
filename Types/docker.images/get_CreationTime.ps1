$this.CreatedAt -replace 
    '(?<=\d)\s(?=\d)', 'T' -replace
    '\s', ':' -replace 
    ':([\-\+])','$1' -replace 
    ':\w{3}$' -replace 
    '\d{2}$', ':$0' -as [DateTime]