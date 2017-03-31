
from GoHeader cimport GoHeader

cdef class GoModule:
	cdef object clib
	cdef str filePath
	cdef GoHeader header
	cdef object __SavePtr
	cdef object __FreePtr
	cdef dict pointerRefCounts

	cdef savePtr(self, unsigned long ptr)
	cdef freePtr(self, unsigned long ptr)

