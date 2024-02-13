#!/bin/bash

dirname="/opt/user-zvC9"

for i in ${dirname}/* ; do
 case "$i" in
 "${dirname}/*" )
  echo Haven\'t found anything under ${dirname}/
  ;;
 *)
  if test -d "${i}/include" ; then 
   if test "x$CPPFLAGS" = "x" ; then
    CPPFLAGS="-I${i}/include"
   else
    CPPFLAGS="-I${i}/include ${CPPFLAGS}"
   fi
  fi
  if test -d "${i}/lib/x86_64-linux-gnu" ; then
   if test "x$LDFLAGS" = "x" ; then
    LDFLAGS="-L${i}/lib/x86_64-linux-gnu"
   else
    LDFLAGS="-L${i}/lib/x86_64-linux-gnu ${LDFLAGS}"
   fi
  fi
  if test -d "${i}/lib" ; then
   if test "x$LDFLAGS" = "x" ; then
    LDFLAGS="-L${i}/lib"
   else
    LDFLAGS="-L${i}/lib ${LDFLAGS}"
   fi
  fi
  if test -d "${i}/lib/x86_64-linux-gnu/pkgconfig" ; then
   if test "x$PKG_CONFIG_PATH" = "x" ; then
    PKG_CONFIG_PATH="${i}/lib/x86_64-linux-gnu/pkgconfig"
   else
    PKG_CONFIG_PATH="${i}/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}"
   fi
  fi
  if test -d "${i}/lib/pkgconfig" ; then
   if test "x$PKG_CONFIG_PATH" = "x" ; then
    PKG_CONFIG_PATH="${i}/lib/pkgconfig"
   else
    PKG_CONFIG_PATH="${i}/lib/pkgconfig:${PKG_CONFIG_PATH}"
   fi
  fi
  if test -d "${i}/lib/x86_64-linux-gnu" ; then
   if test "x${LD_LIBRARY_PATH}" = "x" ; then
    LD_LIBRARY_PATH="${i}/lib/x86_64-linux-gnu"
   else
    LD_LIBRARY_PATH="${i}/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"
   fi
  fi
  if test -d "${i}/lib" ; then
   if test "x${LD_LIBRARY_PATH}" = "x" ; then
    LD_LIBRARY_PATH="${i}/lib"
   else
    LD_LIBRARY_PATH="${i}/lib:${LD_LIBRARY_PATH}"
   fi
  fi
  if test -d "${i}/bin" ; then
   if test "x$PATH" = "x" ; then
	   PATH="${i}/bin"
   else
	   PATH="${i}/bin:${PATH}"
   fi
  fi
  if test -d "${i}/sbin" ; then
   if test "x$PATH" = "x" ; then
	   PATH="${i}/sbin"
   else
	   PATH="${i}/sbin:${PATH}"
   fi
  fi
  ;;
 esac
done

export CPPFLAGS LDFLAGS PKG_CONFIG_PATH

export LD_LIBRARY_PATH PATH

return 0

#LD_LIBRARY_PATH="/opt/custom/lib/x86_64-linux-gnu:/opt/custom/lib"

#CPPFLAGS="-I/opt/custom/include"
#LDFLAGS="-L/opt/custom/lib/x86_64-linux-gnu -L/opt/custom/lib"
#PKG_CONFIG_PATH="/opt/custom/lib/x86_64-linux-gnu/pkgconfig:/opt/custom/lib/pkgconfig"

#export CPPFLAGS LDFLAGS PKG_CONFIG_PATH


#LD_LIBRARY_PATH="/opt/custom/lib/x86_64-linux-gnu:/opt/custom/lib"
#if test "x$PATH" = "x" ; then
#	PATH="/opt/custom/bin:/opt/custom/sbin"
#else
#	PATH="/opt/custom/bin:/opt/custom/sbin:$PATH"
#fi
#export LD_LIBRARY_PATH PATH



#CPPFLAGS="-I/opt/gobject-introspection/include -I/opt/atk/include -I/opt/gdk-pixbuf/include -I/opt/glib-2.72.0/include -I/opt/libepoxy-1.5.9/include -I/opt/libsigc++-3.0.7/include -I/opt/pango-1.50.6/include -I/opt/gtk-4.6.2/include -I/opt/cairo-git/include -I/opt/cairomm-git/include -I/opt/pixman-git/include -I/opt/glibmm-git/include -I/opt/pangomm-git/include -I/opt/graphene-git/include -I/opt/gtkmm-4.6.1/include"
#LDFLAGS="-L/opt/gobject-introspection/lib/x86_64-linux-gnu -L/opt/atk/lib/x86_64-linux-gnu -L/opt/gdk-pixbuf/lib/x86_64-linux-gnu -L/opt/glib-2.72.0/lib/x86_64-linux-gnu -L/opt/libepoxy-1.5.9/lib/x86_64-linux-gnu -L/opt/libsigc++-3.0.7/lib/x86_64-linux-gnu -L/opt/pango-1.50.6/lib/x86_64-linux-gnu -L/opt/gtk-4.6.2/lib/x86_64-linux-gnu -L/opt/cairo-git/lib/x86_64-linux-gnu -L/opt/cairomm-git/lib/x86_64-linux-gnu -L/opt/pixman-git/lib/x86_64-linux-gnu -L/opt/glibmm-git/lib -L/opt/pangomm-git/lib/x86_64-linux-gnu -L/opt/graphene-git/lib/x86_64-linux-gnu -L/opt/gtkmm-4.6.1/lib/x86_64-linux-gnu"
#PKG_CONFIG_PATH="/opt/gobject-introspection/lib/x86_64-linux-gnu/pkgconfig:/opt/atk/lib/x86_64-linux-gnu/pkgconfig:/opt/gdk-pixbuf/lib/x86_64-linux-gnu/pkgconfig:/opt/glib-2.72.0/lib/x86_64-linux-gnu/pkgconfig:/opt/libepoxy-1.5.9/lib/x86_64-linux-gnu/pkgconfig:/opt/libsigc++-3.0.7/lib/x86_64-linux-gnu/pkgconfig:/opt/pango-1.50.6/lib/x86_64-linux-gnu/pkgconfig:/opt/gtk-4.6.2/lib/x86_64-linux-gnu/pkgconfig:/opt/cairo-git/lib/x86_64-linux-gnu/pkgconfig:/opt/cairomm-git/lib/x86_64-linux-gnu/pkgconfig:/opt/pixman-git/lib/x86_64-linux-gnu/pkgconfig:/opt/glibmm-git/lib/pkgconfig:/opt/pangomm-git/lib/x86_64-linux-gnu/pkgconfig:/opt/graphene-git/lib/x86_64-linux-gnu/pkgconfig:/opt/gtkmm-4.6.1/lib/x86_64-linux-gnu/pkgconfig"



#export CPPFLAGS LDFLAGS PKG_CONFIG_PATH

#LD_LIBRARY_PATH="/opt/gobject-introspection/lib/x86_64-linux-gnu:/opt/atk/lib/x86_64-linux-gnu:/opt/gdk-pixbuf/lib/x86_64-linux-gnu:/opt/glib-2.72.0/lib/x86_64-linux-gnu:/opt/libepoxy-1.5.9/lib/x86_64-linux-gnu:/opt/libsigc++-3.0.7/lib/x86_64-linux-gnu:/opt/pango-1.50.6/lib/x86_64-linux-gnu:/opt/gtk-4.6.2/lib/x86_64-linux-gnu:/opt/cairo-git/lib/x86_64-linux-gnu:/opt/cairomm-git/lib/x86_64-linux-gnu:/opt/pixman-git/lib/x86_64-linux-gnu:/opt/glibmm-git/lib:/opt/pangomm-git/lib/x86_64-linux-gnu:/opt/graphene-git/lib/x86_64-linux-gnu:/opt/gtkmm-4.6.1/lib/x86_64-linux-gnu"
#if test "x$PATH" = "x" ; then
#	PATH="/opt/gobject-introspection/bin:/opt/atk/bin:/opt/gdk-pixbuf/bin:/opt/glib-2.72.0/bin:/opt/libepoxy-1.5.9/bin:/opt/libsigc++-3.0.7/bin:/opt/pango-1.50.6/bin:/opt/gtk-4.6.2/bin:/opt/cairo-git/bin:/opt/cairomm-git/bin:/opt/pixman-git/bin"
#else
#	PATH="/opt/gobject-introspection/bin:/opt/atk/bin:/opt/gdk-pixbuf/bin:/opt/glib-2.72.0/bin:/opt/libepoxy-1.5.9/bin:/opt/libsigc++-3.0.7/bin:/opt/pango-1.50.6/bin:/opt/gtk-4.6.2/bin:/opt/cairo-git/bin:/opt/cairomm-git/bin:/opt/pixman-git/bin:$PATH"
#fi
#export LD_LIBRARY_PATH PATH

