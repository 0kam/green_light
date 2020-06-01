---
title: "Rで青空文庫のテキストを著者ごとに取得する"
date: 2020-06-01T12:06:46+09:00
draft: false
---
## はじめに
Word2VecやVAEを使ったテキスト潜在意味空間について興味を持ち始めました。 

ここでは手始めにRのWebスクレイピングパッケージ[rvest](https://rvest.tidyverse.org/)を使って青空文庫のテキストを、著者ごとに一気にダウンロードし、ルビの削除などの下処理をします。 

ZIPファイルのダウンロードからテキストファイルの保存までは、[RMeCabのサポートページの関数](http://rmecab.jp/wiki/index.php?R%A4%CE%C8%F7%CB%BA%CF%BF)を流用しています。 

aozora_all()は作者別作品リストのURLを引数に取って、ワーキングディレクトリ直下に作品別のテキストファイルを、NORUBYディレクトリ内にルビを削除したテキストファイルを保存します。 

まだあまり試せておらず、すべての作家で動く保証はありませんので試し試し使ってください。 

作品ごとにダウンロードするときは、aozora_all()ではなくaozora()を使ってください。 

## Rコード
```R
# aozora.R
# 青空文庫の作家別作品リストURLから公開されている作品のテキストをダウンロードし、ルビ等を消す
# aozora()はRMeCabのホームページのものを流用　http://rmecab.jp/wiki/index.php?RMeCabFunctions


library(tidyverse)
library(rvest)

# 作者別作品リストのURLと作者ID、作品IDから作品のZIPファイルのURLを取得
get_zip_url <- function(index_url, author_id, title_id) {
  title_url <- paste0("https://www.aozora.gr.jp/cards/", 
                      formatC(as.integer(author_id), width = 6, flag = "0"), 
                      "/card", 
                      title_id, 
                      ".html")
  title_html <- read_html(title_url)
  data_table <- title_html %>% 
    html_nodes("table.download") %>%
    html_table()
  zip_url <- paste0(str_extract(title_url, ".*[0-9]{6}/"),
                    "files/",
                    data_table[[1]]$`ファイル名（リンク）`[1])
  return(zip_url)
}

# 作者別作品リストのURLから、公開されている作品のURLを取得
get_aozora_titles <- function(index_url) {
  # 作者IDを取得
  author_id <- index_url %>%
    str_extract("person[0-9]+.") %>%
    str_extract("[0-9]+")
  
  # 作品名のリストを取得
  nodes <- read_html(index_url) %>%
    html_nodes("ol")
  titles_df <- nodes[1] %>% # 作業中の作品を削除
    html_nodes("li") %>%
    html_text() %>%
    as_tibble() %>%
    mutate(index_url = index_url,
           author_id = as.integer(author_id)) %>%
    rename(title = value) %>%
    mutate(title = str_replace_all(.$title, "（.+?）", ""),
           title_id = str_replace_all(.$title, "[^0-9]", "")
    )
  
  zip_urls <- titles_df %>%
    select(-title) %>%
    pmap(get_zip_url) %>%
    unlist() 
  
  res_df <- titles_df %>%
    bind_cols(zip_url = zip_urls)
  return(res_df)
}

# ZIPをダウンロードし、ルビを削除、テキストでNORUBYディレクトリに保存
# http://rmecab.jp/wiki/index.php?RMeCabFunctions
aozora <- function(url = NULL, txtname  = NULL){
  enc <-  switch(.Platform$pkgType, "win.binary" = "CP932", "UTF-8")
  if (is.null(url)) stop ("specify URL")
  tmp <- unlist (strsplit (url, "/"))
  tmp <- tmp [length (tmp)]
  
  curDir <- getwd()
  tmp <- paste(curDir, tmp, sep = "/")
  download.file (url, tmp)
  
  textF <- unzip (tmp)
  unlink (tmp)
  
  if(!file.exists (textF)) stop ("something wrong!")
  if (is.null(txtname)) txtname <- paste(unlist(strsplit(basename (textF), ".txt$")))
  if (txtname != "NORUBY")  {
    
    newDir <- paste(dirname (textF), "NORUBY", sep = "/")
    
    if (! file.exists (newDir)) dir.create (newDir)
    
    newFile <- paste (newDir,  "/", txtname, "2.txt", sep = "")
    
    con <- file(textF, 'r', encoding = "CP932" )
    outfile <- file(newFile, 'w', encoding = enc)
    flag <- 0;
    reg1 <- enc2native ("\U005E\U5E95\U672C")
    reg2 <- enc2native ("\U3010\U5165\U529B\U8005\U6CE8\U3011")
    reg3 <- enc2native ("\UFF3B\UFF03\U005B\U005E\UFF3D\U005D\U002A\UFF3D")
    reg4 <- enc2native ("\U300A\U005B\U005E\U300B\U005D\U002A\U300B")
    reg5 <- enc2native ("\UFF5C")
    while (length(input <- readLines(con, n=1, encoding = "CP932")) > 0){
      if (grepl(reg1, input)) break ;
      if (grepl(reg2, input)) break;
      if (grepl("^------", input)) {
        flag <- !flag
        next;
      }
      if (!flag){
        input <- gsub (reg3, "", input, perl = TRUE)
        input <- gsub (reg4, "", input, perl = TRUE)
        input <- gsub (reg5, "", input, perl = TRUE)
        writeLines(input, con=outfile)
      }
    }
    close(con); close(outfile)
    return (newDir);
  }
}

# 作者別インデックスのURLからテキストを取得し、NORUBYディレクトリに保存
aozora_all <- function(index_url) {
  df <- get_aozora_titles(index_url)
  map(df$zip_url, Aozora)
}

# example
if(0) {
  # 尾形亀之助の例
  kamenosuke <- "https://www.aozora.gr.jp/index_pages/person874.html#sakuhin_list_1"
  aozora_all(kamenosuke)
}

```
