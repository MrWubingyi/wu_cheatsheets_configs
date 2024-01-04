message("===== install cmake =====")

install(
  TARGETS 
    ${AppName}
  RUNTIME DESTINATION
    ${INSTALL_BINDIR}
)


if (dpi_files STREQUAL "")
  message("empty after dpi_files = ${dpi_files}")
else()
  install(
    FILES 
      ${dpi_files}
    DESTINATION
      ${INSTALL_ROOTDIR}
  )
  message("after dpi_files = ${dpi_files}")
  endif()
  
  
if (dpi_dirs STREQUAL "")
  message("empty after dpi_dirs = ${dpi_dirs}")
else()
  install(
    DIRECTORY  
      ${dpi_dirs}
    DESTINATION
      ${INSTALL_ROOTDIR}
  )
  message("after dpi_dirs = ${dpi_dirs}")
endif()

if (dpi_bins STREQUAL "")
  message("empty after dpi_bins = ${dpi_bins}")
else()
  install(
    PROGRAMS  
      ${dpi_bins}
    DESTINATION
      ${INSTALL_ROOTDIR}
  )
  message("after dpi_bins = ${dpi_bins}")
endif()
