/*
 * list.h
 *
 * Copyright (C) 1989, 1991, Craig E. Kolb
 * All rights reserved.
 *
 * This software may be freely copied, modified, and redistributed
 * provided that this copyright notice is preserved on all copies.
 *
 * You may not distribute this software, in whole or in part, as part of
 * any commercial product without the express consent of the authors.
 *
 * There is no warranty or other guarantee of fitness of this software
 * for any purpose.  It is provided solely "as is".
 *
 * $Id: list.h,v 1.1 2002-12-18 18:36:42 pepe Exp $
 *
 * $Log: not supported by cvs2svn $
 * Revision 4.0  91/07/17  14:38:45  kolb
 * Initial version.
 * 
 */
#ifndef LIST_H
#define LIST_H

#define GeomListCreate()	GeomCreate((GeomRef)ListCreate(), ListMethods())

/*
 * List object
 */
typedef struct {
	struct Geom *list;		/* List of prims/objs. in object */
	struct Geom *unbounded;	/* List of unbounded prims. */
	Float bounds[2][3];		/* Bounding box of object */
} List;


extern GeomRef	ListCreate(void);
extern Methods	*ListMethods();

#endif /* LIST_H */
