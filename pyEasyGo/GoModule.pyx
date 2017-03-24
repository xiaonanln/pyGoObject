
import os
import ctypes
from ctypes import CDLL
from ctypes import cdll

from GoHeader cimport GoHeader
from GoHeader cimport GoFuncDecl
from GoHeader cimport GoType
from cgocheck cimport cgocheck

from errors import GolangError

cdef class _FuncCaller:
	cdef object func
	cdef GoFuncDecl decl

	def __cinit__(self, object func, GoFuncDecl decl):
		self.func = func
		self.decl = decl
		func.restype = decl.getResType()

		if decl.retType.containsGoPointer() and cgocheck() != 0:
			raise GolangError("return value contains Go pointer and cgocheck=%d" % cgocheck())

	def __call__(self, *_args):
		cdef list args = self.decl.convertArgs(_args)
		ret = self.func( *args )
		return self.decl.restoreReturnVal(ret)

cdef class GoModule:

	cdef object clib
	cdef str filePath
	cdef GoHeader header

	def __cinit__(self, str soFilePath):
		self.filePath = soFilePath
		assert self.filePath.endswith('.so'), self.filePath
		self.clib = cdll.LoadLibrary(soFilePath)
		self.header = GoHeader(self.filePath[:-3] + '.h')
		print soFilePath, "==>", self.clib, self.header
	
	def __str__(self):
		return "GoModule<%s>" % self.filePath

	def __getattr__(self, funcName):
		func = getattr(self.clib, funcName)
		funcDecl = self.header.getFuncDecl(funcName)
		funcCaller = _FuncCaller(func, funcDecl)
		# setattr(self, funcName, funcCaller)
		return funcCaller

