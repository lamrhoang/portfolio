locals {
  content_types = {
    ".html" : "text/html",
    ".css" : "text/css",
    ".js" : "text/javascript",
    ".text" : "text/plain",
    ".ico" : "image/x-icon",
    ".pdf" : "application/pdf",
    ".png" : "image/png",
    ".jpg" : "image/jpeg"
  }

  s3_filepath = "./dist/angular-portfolio-website"
}