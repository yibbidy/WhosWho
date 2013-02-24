// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)
//

#include "utilities.h"
#include "glm/glm.hpp"

float MTH_Round(float value) {
	int intVal = (int)value;
	if( value - intVal >= .5 ) {
		return (float)(intVal+1);
	} else if( value - intVal <= -0.5 ) {
		return (float)(intVal-1);
	} else {
		return (float)intVal;
	}
}

float MTH_Sign(float inValue) {
	return (inValue >= 0) ? 1.0f : -1.0f;
}

float MTH_RandomFloat(float inMin, float inMax) {
    float value = (rand() / (float)RAND_MAX) * (inMax-inMin) + inMin;
    return value;
}
float MTH_RandomInt(int inMin, int inMax) {
    return MTH_Round(MTH_RandomFloat(inMin, inMax));
}


void VEC2_Set(float inX, float inY, float * outV) {
	outV[0] = inX;
	outV[1] = inY;
}

void VEC2_Equate(float * inV, float * outV) {
	outV[0] = inV[0];
	outV[1] = inV[1];
}

void VEC2_Perpendicular(float * inV, float * outV) {
	float v[] = { -inV[1], inV[0] };
	VEC2_Equate(v, outV);
}

float VEC2_Dot(float * inV1, float * inV2) {
	return inV1[0]*inV2[0] + inV1[1]*inV2[1];
}

float VEC2_MagnitudeSq(float * inV) { 
	return inV[0]*inV[0] + inV[1]*inV[1];
}

float VEC2_Magnitude(float * inV) { 
	return sqrtf(inV[0]*inV[0] + inV[1]*inV[1]);
}

void VEC2_Add(float * inV1, float * inV2, float * outV) {
	outV[0] = inV1[0] + inV2[0];
	outV[1] = inV1[1] + inV2[1];
}

void VEC2_Subtract(float * inV1, float * inV2, float * outV) {
	outV[0] = inV1[0] - inV2[0];
	outV[1] = inV1[1] - inV2[1];
}

void VEC2_Multiply(float * inV1, float inFactor, float * outV) {
	outV[0] = inV1[0] * inFactor;
	outV[1] = inV1[1] * inFactor;
}

float VEC2_Distance(float * inV0, float * inV1) {
	float diff[2];
	VEC2_Subtract(inV0, inV1, diff);
	return VEC2_Magnitude(diff);
}

void VEC3_Set(float x, float y, float z, float * outVec) {
	outVec[0] = x;
	outVec[1] = y;
	outVec[2] = z;
}
void VEC4_Set(float x, float y, float z, float w, float * outVec) {
	outVec[0] = x;
	outVec[1] = y;
	outVec[2] = z;
	outVec[3] = w;
}

void VEC3_Interpolate(float * inV1, float * inV2, float inT, float * outV) {
	outV[0] = inV1[0]*(1-inT) + inV2[0]*inT;
	outV[1] = inV1[1]*(1-inT) + inV2[1]*inT;
	outV[2] = inV1[2]*(1-inT) + inV2[2]*inT;
}

void VEC3_Equate(float * vec3, float * output_vec3) {
	output_vec3[0] = vec3[0];
	output_vec3[1] = vec3[1];
	output_vec3[2] = vec3[2];
}
void VEC4_Equate(float * inVec4, float * outVec4) {
	outVec4[0] = inVec4[0];
	outVec4[1] = inVec4[1];
	outVec4[2] = inVec4[2];
	outVec4[3] = inVec4[3];
}

void VEC3_Negate(float * vec3) {
	vec3[0] = -vec3[0];
	vec3[1] = -vec3[1];
	vec3[2] = -vec3[2];
}
void VEC3_Negate(float * vec3, float * outV) {
	outV[0] = -vec3[0];
	outV[1] = -vec3[1];
	outV[2] = -vec3[2];
}
float VEC3_Dot(float * first_vec3, float * second_vec3) {
	return first_vec3[0]*second_vec3[0] + first_vec3[1]*second_vec3[1] + first_vec3[2]*second_vec3[2];
}

float VEC3_Magnitude_Sq(float * vec3) {
	return vec3[0]*vec3[0] + vec3[1]*vec3[1] + vec3[2]*vec3[2];
}

float VEC3_Magnitude(float * vec3) {
	return sqrt(vec3[0]*vec3[0] + vec3[1]*vec3[1] + vec3[2]*vec3[2]);
}

float VEC3_DistanceBetween(float * inV1, float * inV2) {
	float diff[3];
	VEC3_Subtract(inV1, inV2, diff);
	return VEC3_Magnitude(diff);
}

float VEC3_DistanceBetween_Sq(float * inV1, float * inV2) {
	float diff[3];
	VEC3_Subtract(inV1, inV2, diff);
	return VEC3_Magnitude_Sq(diff);
}

void VEC3_Normalize(float * vec3, float * normalized_vec3) {
	float magnitude = VEC3_Magnitude(vec3);
	if( magnitude == 0 ) {
		magnitude = 1;
	}

	normalized_vec3[0] = vec3[0] / magnitude;
	normalized_vec3[1] = vec3[1] / magnitude;
	normalized_vec3[2] = vec3[2] / magnitude;
}

void VEC3_Normalize(float * vec3) {
	VEC3_Normalize(vec3, vec3);
}

void VEC3_Cross(float * a_vec3, float * b_vec3, float * crossed_vec3) {
	crossed_vec3[0] = a_vec3[1]*b_vec3[2] - a_vec3[2]*b_vec3[1];
	crossed_vec3[1] = -(a_vec3[0]*b_vec3[2] - a_vec3[2]*b_vec3[0]);
	crossed_vec3[2] = a_vec3[0]*b_vec3[1] - a_vec3[1]*b_vec3[0];
}

void VEC3_Difference(float * a_vec3, float * b_vec3, float * difference_vec3) {
	difference_vec3[0] = b_vec3[0] - a_vec3[0];
	difference_vec3[1] = b_vec3[1] - a_vec3[1];
	difference_vec3[2] = b_vec3[2] - a_vec3[2];
}

void VEC3_Swap(float * a_vec3, float * b_vec3) {
	float vec3[3];
	vec3[0] = a_vec3[0];
	vec3[1] = a_vec3[1];
	vec3[2] = a_vec3[2];

	a_vec3[0] = b_vec3[0];
	a_vec3[1] = b_vec3[1];
	a_vec3[2] = b_vec3[2];

	b_vec3[0] = vec3[0];
	b_vec3[1] = vec3[1];
	b_vec3[2] = vec3[2];
}

void VEC3_Add(float * first_vec3, float * second_vec3, float * output_vec3) {
	output_vec3[0] = first_vec3[0] + second_vec3[0];
	output_vec3[1] = first_vec3[1] + second_vec3[1];
	output_vec3[2] = first_vec3[2] + second_vec3[2];
}

void VEC3_Subtract(float * first_vec3, float * second_vec3, float * output_vec3) {
	output_vec3[0] = first_vec3[0] - second_vec3[0];
	output_vec3[1] = first_vec3[1] - second_vec3[1];
	output_vec3[2] = first_vec3[2] - second_vec3[2];
}

void VEC3_Multiply(float * first_vec3, float * second_vec3, float * output_vec3) {
	output_vec3[0] = first_vec3[0] * second_vec3[0];
	output_vec3[1] = first_vec3[1] * second_vec3[1];
	output_vec3[2] = first_vec3[2] * second_vec3[2];
}

void VEC3_Multiply(float * vec3, float scalar, float * output_vec3) {
	output_vec3[0] = vec3[0]*scalar;
	output_vec3[1] = vec3[1]*scalar;
	output_vec3[2] = vec3[2]*scalar;
}
void VEC4_Multiply(float * inVec4, float scalar, float * outVec) {
	outVec[0] = inVec4[0]*scalar;
	outVec[1] = inVec4[1]*scalar;
	outVec[2] = inVec4[2]*scalar;
	outVec[3] = inVec4[3]*scalar;
}

void VEC3_Divide(float * inVec3, float scalar, float * outVec) {
	outVec[0] = inVec3[0]/scalar;
	outVec[1] = inVec3[1]/scalar;
	outVec[2] = inVec3[2]/scalar;
}
void VEC4_Divide(float * inVec4, float scalar, float * outVec) {
	outVec[0] = inVec4[0]/scalar;
	outVec[1] = inVec4[1]/scalar;
	outVec[2] = inVec4[2]/scalar;
	outVec[3] = inVec4[3]/scalar;
}

float VEC3_AngleBetween(float * first_vec3, float * second_vec3) {
	float mag1 = VEC3_Magnitude(first_vec3);

	float mag2 = VEC3_Magnitude(second_vec3);

	float dot = VEC3_Dot(first_vec3, second_vec3);

	float angleBetween = glm::acos(glm::max(glm::min(dot / (mag1*mag2), 1.0f), -1.0f) );

	return angleBetween;
}

void VEC3_Average(float * inV1, float * inV2, float * outAverage) {
	VEC3_Add(inV1, inV2, outAverage);
	VEC3_Multiply(outAverage, 0.5f, outAverage);
}

void VEC3_Mix(float * inV0, float * inV1, float inT, float * outV) {
	float t0 = 1-inT;
	float t1 = inT;
	outV[0] = t0*inV0[0] + t1*inV1[0];
	outV[1] = t0*inV0[1] + t1*inV1[1];
	outV[2] = t0*inV0[2] + t1*inV1[2];
}

void VEC3_MAT4_Multiply(float * row_vec3, float * mat4, float * column_vec3) {
	float result[3];

	result[0] = row_vec3[ 0]*mat4[ 0] + row_vec3[ 1]*mat4[ 1] + row_vec3[ 2]*mat4[ 2] + 1*mat4[ 3];
	result[1] = row_vec3[ 0]*mat4[ 4] + row_vec3[ 1]*mat4[ 5] + row_vec3[ 2]*mat4[ 6] + 1*mat4[ 7];
	result[2] = row_vec3[ 0]*mat4[ 8] + row_vec3[ 1]*mat4[ 9] + row_vec3[ 2]*mat4[10] + 1*mat4[11];

	memcpy(column_vec3, result, 3*sizeof(float));
}

void VEC4_MAT4_Multiply(float * inV, float * inM, float * outV) {
	float result[4];
	
	result[0] = inV[ 0]*inM[ 0] + inV[ 1]*inM[ 1] + inV[ 2]*inM[ 2] + inV[ 3]*inM[ 3];
	result[1] = inV[ 0]*inM[ 4] + inV[ 1]*inM[ 5] + inV[ 2]*inM[ 6] + inV[ 3]*inM[ 7];
	result[2] = inV[ 0]*inM[ 8] + inV[ 1]*inM[ 9] + inV[ 2]*inM[10] + inV[ 3]*inM[11];
	result[3] = inV[ 0]*inM[12] + inV[ 1]*inM[13] + inV[ 2]*inM[14] + inV[ 3]*inM[15];

	memcpy(outV, result, sizeof(float)*4);
}

void MAT4_ExtractCol3(float * mat4, int col, float * vec3) {
    vec3[0] = mat4[col*4+0];
    vec3[1] = mat4[col*4+1];
    vec3[2] = mat4[col*4+2];
}

void MAT4_ExtractRow3(float * mat4, int row, float * vec3) {
	vec3[0] = mat4[row];
	vec3[1] = mat4[row+4];
	vec3[2] = mat4[row+8];
}

void MAT4_Equate(float * inMat, float * outMat) {
	memcpy(outMat, inMat, sizeof(float)*16);
}

void MAT4_SetCol3(int col, float * vec3, float * mat4) {
	mat4[col*4+0] = vec3[0];
	mat4[col*4+1] = vec3[1];
	mat4[col*4+2] = vec3[2];
}

void MAT4_LoadIdentity(float * mat4) {
	mat4[0] = 1;
	mat4[1] = 0;
	mat4[2] = 0;
	mat4[3] = 0;
	mat4[4] = 0;
	mat4[5] = 1;
	mat4[6] = 0;
	mat4[7] = 0;
	mat4[8] = 0;
	mat4[9] = 0;
	mat4[10] = 1;
	mat4[11] = 0;
	mat4[12] = 0;
	mat4[13] = 0;
	mat4[14] = 0;
	mat4[15] = 1;
}

void MAT4_VEC3_Multiply(float * mat4, float * column_vec3, float * row_vec3) {
    float result[3];
    
	result[0] = mat4[ 0]*column_vec3[ 0] + mat4[ 4]*column_vec3[ 1] + mat4[ 8]*column_vec3[ 2] + mat4[12]*1;
	result[1] = mat4[ 1]*column_vec3[ 0] + mat4[ 5]*column_vec3[ 1] + mat4[ 9]*column_vec3[ 2] + mat4[13]*1;
	result[2] = mat4[ 2]*column_vec3[ 0] + mat4[ 6]*column_vec3[ 1] + mat4[10]*column_vec3[ 2] + mat4[14]*1;
    
    VEC3_Equate(result, row_vec3);
}

void MAT4_VEC4_MatrixVectorMultiply(float * mat4, float * column_vec4, float * out_vec4) {
	out_vec4[0] = mat4[ 0]*column_vec4[ 0] + mat4[ 4]*column_vec4[ 1] + mat4[ 8]*column_vec4[ 2] + mat4[12]*column_vec4[ 3];
	out_vec4[1] = mat4[ 1]*column_vec4[ 0] + mat4[ 5]*column_vec4[ 1] + mat4[ 9]*column_vec4[ 2] + mat4[13]*column_vec4[ 3];
	out_vec4[2] = mat4[ 2]*column_vec4[ 0] + mat4[ 6]*column_vec4[ 1] + mat4[10]*column_vec4[ 2] + mat4[14]*column_vec4[ 3];
	out_vec4[3] = mat4[ 3]*column_vec4[ 0] + mat4[ 7]*column_vec4[ 1] + mat4[11]*column_vec4[ 2] + mat4[15]*column_vec4[ 3];
}

void MAT4_Multiply(float * first_mat4, float * second_mat4, float * output_mat4) {
	float result[16];

	result[ 0] = first_mat4[ 0]*second_mat4[ 0] + first_mat4[ 4]*second_mat4[ 1] + first_mat4[ 8]*second_mat4[ 2] + first_mat4[12]*second_mat4[ 3];
	result[ 1] = first_mat4[ 1]*second_mat4[ 0] + first_mat4[ 5]*second_mat4[ 1] + first_mat4[ 9]*second_mat4[ 2] + first_mat4[13]*second_mat4[ 3];
	result[ 2] = first_mat4[ 2]*second_mat4[ 0] + first_mat4[ 6]*second_mat4[ 1] + first_mat4[10]*second_mat4[ 2] + first_mat4[14]*second_mat4[ 3];
	result[ 3] = first_mat4[ 3]*second_mat4[ 0] + first_mat4[ 7]*second_mat4[ 1] + first_mat4[11]*second_mat4[ 2] + first_mat4[15]*second_mat4[ 3];

	result[ 4] = first_mat4[ 0]*second_mat4[ 4] + first_mat4[ 4]*second_mat4[ 5] + first_mat4[ 8]*second_mat4[ 6] + first_mat4[12]*second_mat4[ 7];
	result[ 5] = first_mat4[ 1]*second_mat4[ 4] + first_mat4[ 5]*second_mat4[ 5] + first_mat4[ 9]*second_mat4[ 6] + first_mat4[13]*second_mat4[ 7];
	result[ 6] = first_mat4[ 2]*second_mat4[ 4] + first_mat4[ 6]*second_mat4[ 5] + first_mat4[10]*second_mat4[ 6] + first_mat4[14]*second_mat4[ 7];
	result[ 7] = first_mat4[ 3]*second_mat4[ 4] + first_mat4[ 7]*second_mat4[ 5] + first_mat4[11]*second_mat4[ 6] + first_mat4[15]*second_mat4[ 7];

	result[ 8] = first_mat4[ 0]*second_mat4[ 8] + first_mat4[ 4]*second_mat4[ 9] + first_mat4[ 8]*second_mat4[10] + first_mat4[12]*second_mat4[11];
	result[ 9] = first_mat4[ 1]*second_mat4[ 8] + first_mat4[ 5]*second_mat4[ 9] + first_mat4[ 9]*second_mat4[10] + first_mat4[13]*second_mat4[11];
	result[10] = first_mat4[ 2]*second_mat4[ 8] + first_mat4[ 6]*second_mat4[ 9] + first_mat4[10]*second_mat4[10] + first_mat4[14]*second_mat4[11];
	result[11] = first_mat4[ 3]*second_mat4[ 8] + first_mat4[ 7]*second_mat4[ 9] + first_mat4[11]*second_mat4[10] + first_mat4[15]*second_mat4[11];

	result[12] = first_mat4[ 0]*second_mat4[12] + first_mat4[ 4]*second_mat4[13] + first_mat4[ 8]*second_mat4[14] + first_mat4[12]*second_mat4[15];
	result[13] = first_mat4[ 1]*second_mat4[12] + first_mat4[ 5]*second_mat4[13] + first_mat4[ 9]*second_mat4[14] + first_mat4[13]*second_mat4[15];
	result[14] = first_mat4[ 2]*second_mat4[12] + first_mat4[ 6]*second_mat4[13] + first_mat4[10]*second_mat4[14] + first_mat4[14]*second_mat4[15];
	result[15] = first_mat4[ 3]*second_mat4[12] + first_mat4[ 7]*second_mat4[13] + first_mat4[11]*second_mat4[14] + first_mat4[15]*second_mat4[15];

	memcpy(output_mat4, result, sizeof(float)*16);
}

void MAT4_TransposeUpper3(float * mat4, float * transpose_mat4) {
	transpose_mat4[0] = mat4[0];
	transpose_mat4[1] = mat4[4];
	transpose_mat4[2] = mat4[8];
	transpose_mat4[3] = mat4[3];
	transpose_mat4[4] = mat4[1];
	transpose_mat4[5] = mat4[5];
	transpose_mat4[6] = mat4[9];
	transpose_mat4[7] = mat4[7];
	transpose_mat4[8] = mat4[2];
	transpose_mat4[9] = mat4[6];
	transpose_mat4[10] = mat4[10];
	transpose_mat4[11] = mat4[11];
	transpose_mat4[12] = mat4[3];
	transpose_mat4[13] = mat4[7];
	transpose_mat4[14] = mat4[11];
	transpose_mat4[15] = mat4[15];
}

void MAT4_Transpose(float * inOutMat) {
    std::swap(inOutMat[1], inOutMat[5]);
    std::swap(inOutMat[2], inOutMat[8]);
	std::swap(inOutMat[3], inOutMat[12]);
	std::swap(inOutMat[6], inOutMat[9]);
	std::swap(inOutMat[7], inOutMat[13]);
	std::swap(inOutMat[11], inOutMat[14]);
}

void MAT4_SetEqual(float * mat4, float * output_mat4) {
	for( int i=0; i<16; i++ ) {
		output_mat4[i] = mat4[i];
	}
}

void MAT4_InvertQuick(float * inMat, float * outMat) {
	memcpy(outMat, inMat, sizeof(float)*16);

	float offset[3];
	MAT4_ExtractCol3(inMat, 3, offset);
	VEC3_Negate(offset);

	outMat[12] = VEC3_Dot(offset, inMat+0);
	outMat[13] = VEC3_Dot(offset, inMat+4);
	outMat[14] = VEC3_Dot(offset, inMat+8);
	std::swap(outMat[1], outMat[4]);
	std::swap(outMat[2], outMat[8]);
	std::swap(outMat[6], outMat[9]);
}

float MTH_DegToRad(float deg) {
    return deg*3.141592654f/180.0f;
}

float MTH_RadToDeg(float rad) {
    return rad*180.0f/3.141592654f;
}

void MAT4_MakeZRotation(float deg, float * zRotation_mat4) {
	float rad = MTH_DegToRad(deg);

	float c = cos(rad);
	float s = sin(rad);
	zRotation_mat4[0] = c;
	zRotation_mat4[1] = s;
	zRotation_mat4[2] = 0;
	zRotation_mat4[3] = 0;
	zRotation_mat4[4] = -s;
	zRotation_mat4[5] = c;
	zRotation_mat4[6] = 0;
	zRotation_mat4[7] = 0;
	zRotation_mat4[8] = 0;
	zRotation_mat4[9] = 0;
	zRotation_mat4[10] = 1;
	zRotation_mat4[11] = 0;
	zRotation_mat4[12] = 0;
	zRotation_mat4[13] = 0;
	zRotation_mat4[14] = 0;
	zRotation_mat4[15] = 1;

}

void MAT4_MakeXRotation(float deg, float * xRotation_mat4) {
	float rad = MTH_DegToRad(deg);

	float c = cos(rad);
	float s = sin(rad);
	xRotation_mat4[0] = 1;
	xRotation_mat4[1] = 0;
	xRotation_mat4[2] = 0;
	xRotation_mat4[3] = 0;
	xRotation_mat4[4] = 0;
	xRotation_mat4[5] = c;
	xRotation_mat4[6] = s;
	xRotation_mat4[7] = 0;
	xRotation_mat4[8] = 0;
	xRotation_mat4[9] = -s;
	xRotation_mat4[10] = c;
	xRotation_mat4[11] = 0;
	xRotation_mat4[12] = 0;
	xRotation_mat4[13] = 0;
	xRotation_mat4[14] = 0;
	xRotation_mat4[15] = 1;

}
void MAT4_MakeYRotation(float deg, float * xRotation_mat4) {
	float rad = MTH_DegToRad(deg);

	float c = cos(rad);
	float s = sin(rad);
	xRotation_mat4[0] = c;
	xRotation_mat4[1] = 0;
	xRotation_mat4[2] = s;
	xRotation_mat4[3] = 0;
	xRotation_mat4[4] = 0;
	xRotation_mat4[5] = 1;
	xRotation_mat4[6] = 0;
	xRotation_mat4[7] = 0;
	xRotation_mat4[8] = -s;
	xRotation_mat4[9] = 0;
	xRotation_mat4[10] = c;
	xRotation_mat4[11] = 0;
	xRotation_mat4[12] = 0;
	xRotation_mat4[13] = 0;
	xRotation_mat4[14] = 0;
	xRotation_mat4[15] = 1;

}
void MAT4_MakeArbitraryRotation(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * rotation_mat4) {
	float c = cos(inAngleRad);
	float s = sin(inAngleRad);
	float t = 1-c;
	float & x = inAxisX;
	float & y = inAxisY;
	float & z = inAxisZ;

	rotation_mat4[0] = t*x*x + c;
	rotation_mat4[1] = t*x*y - s*z;
	rotation_mat4[2] = t*x*y + s*y;
	rotation_mat4[3] = 0;
	rotation_mat4[4] = t*x*y + s*z;
	rotation_mat4[5] = t*y*y + c;
	rotation_mat4[6] = t*y*z - s*x;
	rotation_mat4[7] = 0;
	rotation_mat4[8] = t*x*z - s*y;
	rotation_mat4[9] = t*y*z + s*x;
	rotation_mat4[10] = t*z*z + c;
	rotation_mat4[11] = 0;
	rotation_mat4[12] = 0;
	rotation_mat4[13] = 0;
	rotation_mat4[14] = 0;
	rotation_mat4[15] = 1;
}

void MAT4_PostRotate(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * inOutMat) {
    float mat[16];
    MAT4_MakeArbitraryRotation(inAxisX, inAxisY, inAxisZ, inAngleRad, mat);
    
    MAT4_Multiply(inOutMat, mat, inOutMat);
    
}

void MAT4_PreRotate(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * inOutMat) {
    float mat[16];
    MAT4_MakeArbitraryRotation(inAxisX, inAxisY, inAxisZ, inAngleRad, mat);
    
    MAT4_Multiply(mat, inOutMat, inOutMat);
    
}


void MAT4_MakeTranslation(float inX, float inY, float inZ, float * outMat) {
    outMat[0] = 1;
    outMat[1] = 0;
    outMat[2] = 0;
    outMat[3] = 0;
    outMat[4] = 0;
    outMat[5] = 1;
    outMat[6] = 0;
    outMat[7] = 0;
    outMat[8] = 0;
    outMat[9] = 0;
    outMat[10] = 1;
    outMat[11] = 0;
    outMat[12] = inX;
    outMat[13] = inY;
    outMat[14] = inZ;
    outMat[15] = 1;
}

void MAT4_PostTranslate(float inX, float inY, float inZ, float * inOutMat) 
// inOutMat = inOutMat * translateMat
{
    float mat[16];
    MAT4_MakeTranslation(inX, inY, inZ, mat);
    MAT4_Multiply(inOutMat, mat, inOutMat);
}

void MAT4_PreTranslate(float inX, float inY, float inZ, float * inOutMat) 
// inOutMat = inOutMat * translateMat
{
    float mat[16];
    MAT4_MakeTranslation(inX, inY, inZ, mat);
    MAT4_Multiply(mat, inOutMat, inOutMat);
}

void MAT4_MakeScale(float inScaleX, float inScaleY, float inScaleZ, float * outMat) {
    outMat[0] = inScaleX;
    outMat[1] = 0;
    outMat[2] = 0;
    outMat[3] = 0;
    outMat[4] = 0;
    outMat[5] = inScaleY;
    outMat[6] = 0;
    outMat[7] = 0;
    outMat[8] = 0;
    outMat[9] = 0;
    outMat[10] = inScaleZ;
    outMat[11] = 0;
    outMat[12] = 0;
    outMat[13] = 0;
    outMat[14] = 0;
    outMat[15] = 1;
}

void MAT4_PreScale(float inScaleX, float inScaleY, float inScaleZ, float * inOutMat) {
    float mat[16];
    MAT4_MakeScale(inScaleX, inScaleY, inScaleZ, mat);
    MAT4_Multiply(mat, inOutMat, inOutMat);
}

void MAT4_PostScale(float inScaleX, float inScaleY, float inScaleZ, float * inOutMat) {
    float mat[16];
    MAT4_MakeScale(inScaleX, inScaleY, inScaleZ, mat);
    MAT4_Multiply(inOutMat, mat, inOutMat);
}
void MAT4_MakeInversePerspective(float fovy_rad, float aspect, float zNear, float zFar, float * mat4) {
	float f = 1.0f / tan(fovy_rad / 2);
	float dp = zNear - zFar;
	mat4[0] = aspect/f;
	mat4[1] = 0;
	mat4[2] = 0;
	mat4[3] = 0;
	mat4[4] = 0;
	mat4[5] = 1/f;
	mat4[6] = 0;
	mat4[7] = 0;
	mat4[8] = 0;
	mat4[9] = 0;
	mat4[10] = 0;
	mat4[11] = dp/(2*zFar*zNear);
	mat4[12] = 0;
	mat4[13] = 0;
	mat4[14] = -1;
	mat4[15] =(zFar+zNear)/(2*zNear*zFar);
}

void MAT4_MakePerspective(float fovy_rad, float aspect, float zNear, float zFar, float * mat4) {
	float f = 1.0f / tan(fovy_rad / 2);
	mat4[0] = f/aspect;
	mat4[1] = 0;
	mat4[2] = 0;
	mat4[3] = 0;
	mat4[4] = 0;
	mat4[5] = f;
	mat4[6] = 0;
	mat4[7] = 0;
	mat4[8] = 0;
	mat4[9] = 0;
	mat4[10] = (zFar+zNear)/(zNear-zFar);
	mat4[11] = -1;
	mat4[12] = 0;
	mat4[13] = 0;
	mat4[14] = (2*zFar*zNear)/(zNear-zFar);
	mat4[15] = 0;
}

void MAT4_MakeOrtho(float left, float right, float bottom, float top, float zNear, float zFar, float * mat4) {
	float tx = -(right+left) / (right-left);
	float ty = -(top+bottom) / (top-bottom);
	float tz = -(zFar+zNear) / (zFar-zNear);

	mat4[0] = 2.0f / (right-left);
	mat4[1] = 0;
	mat4[2] = 0;
	mat4[3] = 0;
	mat4[4] = 0;
	mat4[5] = 2.0f / (top-bottom);
	mat4[6] = 0;
	mat4[7] = 0;
	mat4[8] = 0;
	mat4[9] = 0;
	mat4[10] = -2.0f / (zFar-zNear);
	mat4[11] = 0;
	mat4[12] = tx;
	mat4[13] = ty;
	mat4[14] = tz;
	mat4[15] = 1;
}

void MAT4_MakeFrustum(float left, float right, float bottom, float top, float zNear, float zFar, float * mat4) {
	float A = (right+left) / (right-left);
	float B = (top+bottom) / (top-bottom);
	float C = -(zFar+zNear) / (zFar-zNear);
	float D = -(2*zFar*zNear) / (zFar-zNear);

	mat4[0] = (2*zNear) / (right-left);
	mat4[1] = 0;
	mat4[2] = 0;
	mat4[3] = 0;
	mat4[4] = 0;
	mat4[5] = (2*zNear) / (top-bottom);
	mat4[6] = 0;
	mat4[7] = 0;
	mat4[8] = A;
	mat4[9] = B;
	mat4[10] = C;
	mat4[11] = -1;
	mat4[12] = 0;
	mat4[13] = 0;
	mat4[14] = D;
	mat4[15] = 0;
}

void MAT4_Translate(float inX, float inY, float inZ, float * inOutMat4) {
	inOutMat4[12] += inX;
	inOutMat4[13] += inY;
	inOutMat4[14] += inZ;
}

void MAT4_SetUpper3x3Rowwise(float * outMat, float * inR0, float * inR1, float * inR2) {
	outMat[0] = inR0[0];
	outMat[4] = inR0[1];
	outMat[8] = inR0[2];

	outMat[1] = inR1[0];
	outMat[5] = inR1[1];
	outMat[9] = inR1[2];

	outMat[2] = inR2[0];
	outMat[6] = inR2[1];
	outMat[10] = inR2[2];
}
void MAT4_SetUpper3x3(float * outMat, float * inR0, float * inR1, float * inR2) {
	outMat[0] = inR0[0];
	outMat[1] = inR0[1];
	outMat[2] = inR0[2];

	outMat[4] = inR1[0];
	outMat[5] = inR1[1];
	outMat[6] = inR1[2];

	outMat[8] = inR2[0];
	outMat[9] = inR2[1];
	outMat[10] = inR2[2];
}

void MAT4_LookAt(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ, float * viewMatrix) {
	float * m = viewMatrix;

	float eye[] = { eyeX, eyeY, eyeZ };
	float center[] = { centerX, centerY, centerZ };
	float up[] = { upX, upY, upZ };
	VEC3_Normalize(up);

	float f[3];
	VEC3_Subtract(center, eye, f);
	VEC3_Normalize(f);

	float s[3];
	VEC3_Cross(f, up, s);

	float u[3];
	VEC3_Cross(s, f, u);

	float mat[16] = {
		s[0], u[0], -f[0], 0,
		s[1], u[1], -f[1], 0,
		s[2], u[2], -f[2], 0,
		0, 0, 0, 1 };

	float t[16];
	MAT4_LoadIdentity(t);
	MAT4_Translate(-eyeX, -eyeY, -eyeZ, t);

	MAT4_Multiply(mat, t, m);	
}


void MAT4_VEC4_Multiply(float * mat4, float * column_vec4, float * row_vec4) {
	float result[4];

	result[0] = mat4[ 0]*column_vec4[ 0] + mat4[ 4]*column_vec4[ 1] + mat4[ 8]*column_vec4[ 2] + mat4[12]*column_vec4[ 3];
	result[1] = mat4[ 1]*column_vec4[ 0] + mat4[ 5]*column_vec4[ 1] + mat4[ 9]*column_vec4[ 2] + mat4[13]*column_vec4[ 3];
	result[2] = mat4[ 2]*column_vec4[ 0] + mat4[ 6]*column_vec4[ 1] + mat4[10]*column_vec4[ 2] + mat4[14]*column_vec4[ 3];
	result[3] = mat4[ 3]*column_vec4[ 0] + mat4[ 7]*column_vec4[ 1] + mat4[11]*column_vec4[ 2] + mat4[15]*column_vec4[ 3];

	memcpy(row_vec4, result, 4*sizeof(float));
}


bool MAT4_Invert(const float * mat4, float * outMat) {
	/* Compute inverse of 4x4 transformation matrix.
	Code contributed by Jacques Leroy jle@star.be
	return - true for success, false for failure (singular matrix)
	
	modified from http://webcvs.freedesktop.org/mesa/Mesa/src/glu/mesa/project.c?revision=1.4&view=markup
	*/

/* NB. OpenGL Matrices are COLUMN major. */
#define SWAP_ROWS(a, b) { float *_tmp = a; (a)=(b); (b)=_tmp; }
#define MAT(mat4,r,c) (mat4)[(c)*4+(r)]

	float * out4 = outMat;
	float inv[16];
	if( mat4 == out4 ) { // if input and output point to same memory
		out4 = inv;
	}

   float wtmp[4][8];
   float m0, m1, m2, m3, s;
   float *r0, *r1, *r2, *r3;

   r0 = wtmp[0], r1 = wtmp[1], r2 = wtmp[2], r3 = wtmp[3];

   r0[0] = MAT(mat4, 0, 0), r0[1] = MAT(mat4, 0, 1),
      r0[2] = MAT(mat4, 0, 2), r0[3] = MAT(mat4, 0, 3),
      r0[4] = 1.0, r0[5] = r0[6] = r0[7] = 0.0,
      r1[0] = MAT(mat4, 1, 0), r1[1] = MAT(mat4, 1, 1),
      r1[2] = MAT(mat4, 1, 2), r1[3] = MAT(mat4, 1, 3),
      r1[5] = 1.0, r1[4] = r1[6] = r1[7] = 0.0,
      r2[0] = MAT(mat4, 2, 0), r2[1] = MAT(mat4, 2, 1),
      r2[2] = MAT(mat4, 2, 2), r2[3] = MAT(mat4, 2, 3),
      r2[6] = 1.0, r2[4] = r2[5] = r2[7] = 0.0,
      r3[0] = MAT(mat4, 3, 0), r3[1] = MAT(mat4, 3, 1),
      r3[2] = MAT(mat4, 3, 2), r3[3] = MAT(mat4, 3, 3),
      r3[7] = 1.0, r3[4] = r3[5] = r3[6] = 0.0;

   /* choose pivot - or die */
   if (fabs(r3[0]) > fabs(r2[0]))
      SWAP_ROWS(r3, r2);
   if (fabs(r2[0]) > fabs(r1[0]))
      SWAP_ROWS(r2, r1);
   if (fabs(r1[0]) > fabs(r0[0]))
      SWAP_ROWS(r1, r0);
   if (0.0 == r0[0])
      return false;

   /* eliminate first variable     */
   m1 = r1[0] / r0[0];
   m2 = r2[0] / r0[0];
   m3 = r3[0] / r0[0];
   s = r0[1];
   r1[1] -= m1 * s;
   r2[1] -= m2 * s;
   r3[1] -= m3 * s;
   s = r0[2];
   r1[2] -= m1 * s;
   r2[2] -= m2 * s;
   r3[2] -= m3 * s;
   s = r0[3];
   r1[3] -= m1 * s;
   r2[3] -= m2 * s;
   r3[3] -= m3 * s;
   s = r0[4];
   if (s != 0.0) {
      r1[4] -= m1 * s;
      r2[4] -= m2 * s;
      r3[4] -= m3 * s;
   }
   s = r0[5];
   if (s != 0.0) {
      r1[5] -= m1 * s;
      r2[5] -= m2 * s;
      r3[5] -= m3 * s;
   }
   s = r0[6];
   if (s != 0.0) {
      r1[6] -= m1 * s;
      r2[6] -= m2 * s;
      r3[6] -= m3 * s;
   }
   s = r0[7];
   if (s != 0.0) {
      r1[7] -= m1 * s;
      r2[7] -= m2 * s;
      r3[7] -= m3 * s;
   }

   /* choose pivot - or die */
   if (fabs(r3[1]) > fabs(r2[1]))
      SWAP_ROWS(r3, r2);
   if (fabs(r2[1]) > fabs(r1[1]))
      SWAP_ROWS(r2, r1);
   if (0.0 == r1[1])
      return false;

   /* eliminate second variable */
   m2 = r2[1] / r1[1];
   m3 = r3[1] / r1[1];
   r2[2] -= m2 * r1[2];
   r3[2] -= m3 * r1[2];
   r2[3] -= m2 * r1[3];
   r3[3] -= m3 * r1[3];
   s = r1[4];
   if (0.0 != s) {
      r2[4] -= m2 * s;
      r3[4] -= m3 * s;
   }
   s = r1[5];
   if (0.0 != s) {
      r2[5] -= m2 * s;
      r3[5] -= m3 * s;
   }
   s = r1[6];
   if (0.0 != s) {
      r2[6] -= m2 * s;
      r3[6] -= m3 * s;
   }
   s = r1[7];
   if (0.0 != s) {
      r2[7] -= m2 * s;
      r3[7] -= m3 * s;
   }

   /* choose pivot - or die */
   if (fabs(r3[2]) > fabs(r2[2]))
      SWAP_ROWS(r3, r2);
   if (0.0 == r2[2])
      return false;

   /* eliminate third variable */
   m3 = r3[2] / r2[2];
   r3[3] -= m3 * r2[3], r3[4] -= m3 * r2[4],
      r3[5] -= m3 * r2[5], r3[6] -= m3 * r2[6], r3[7] -= m3 * r2[7];

   /* last check */
   if (0.0 == r3[3])
      return false;

   s = 1.0f / r3[3];		/* now back substitute row 3 */
   r3[4] *= s;
   r3[5] *= s;
   r3[6] *= s;
   r3[7] *= s;

   m2 = r2[3];			/* now back substitute row 2 */
   s = 1.0f / r2[2];
   r2[4] = s * (r2[4] - r3[4] * m2), r2[5] = s * (r2[5] - r3[5] * m2),
      r2[6] = s * (r2[6] - r3[6] * m2), r2[7] = s * (r2[7] - r3[7] * m2);
   m1 = r1[3];
   r1[4] -= r3[4] * m1, r1[5] -= r3[5] * m1,
      r1[6] -= r3[6] * m1, r1[7] -= r3[7] * m1;
   m0 = r0[3];
   r0[4] -= r3[4] * m0, r0[5] -= r3[5] * m0,
      r0[6] -= r3[6] * m0, r0[7] -= r3[7] * m0;

   m1 = r1[2];			/* now back substitute row 1 */
   s = 1.0f / r1[1];
   r1[4] = s * (r1[4] - r2[4] * m1), r1[5] = s * (r1[5] - r2[5] * m1),
      r1[6] = s * (r1[6] - r2[6] * m1), r1[7] = s * (r1[7] - r2[7] * m1);
   m0 = r0[2];
   r0[4] -= r2[4] * m0, r0[5] -= r2[5] * m0,
      r0[6] -= r2[6] * m0, r0[7] -= r2[7] * m0;

   m0 = r0[1];			/* now back substitute row 0 */
   s = 1.0f / r0[0];
   r0[4] = s * (r0[4] - r1[4] * m0), r0[5] = s * (r0[5] - r1[5] * m0),
      r0[6] = s * (r0[6] - r1[6] * m0), r0[7] = s * (r0[7] - r1[7] * m0);

   MAT(out4, 0, 0) = r0[4];
   MAT(out4, 0, 1) = r0[5], MAT(out4, 0, 2) = r0[6];
   MAT(out4, 0, 3) = r0[7], MAT(out4, 1, 0) = r1[4];
   MAT(out4, 1, 1) = r1[5], MAT(out4, 1, 2) = r1[6];
   MAT(out4, 1, 3) = r1[7], MAT(out4, 2, 0) = r2[4];
   MAT(out4, 2, 1) = r2[5], MAT(out4, 2, 2) = r2[6];
   MAT(out4, 2, 3) = r2[7], MAT(out4, 3, 0) = r3[4];
   MAT(out4, 3, 1) = r3[5], MAT(out4, 3, 2) = r3[6];
   MAT(out4, 3, 3) = r3[7];

	if( mat4 == outMat ) { // if input and output point to same memory
		memcpy(outMat, out4, sizeof(float)*16);
	}

   return true;

#undef MAT
#undef SWAP_ROWS
}
void MAT4_Transpose(float * inMat4, float * outMat4) {
	outMat4[ 0] = inMat4[ 0];
	outMat4[ 1] = inMat4[ 4];
	outMat4[ 2] = inMat4[ 8];
	outMat4[ 3] = inMat4[12];
	outMat4[ 4] = inMat4[ 1];
	outMat4[ 5] = inMat4[ 5];
	outMat4[ 6] = inMat4[ 9];
	outMat4[ 7] = inMat4[13];
	outMat4[ 8] = inMat4[ 2];
	outMat4[ 9] = inMat4[ 6];
	outMat4[10] = inMat4[10];
	outMat4[11] = inMat4[14];
	outMat4[12] = inMat4[ 3];
	outMat4[13] = inMat4[ 7];
	outMat4[14] = inMat4[11];
	outMat4[15] = inMat4[15];
}
void MAT4_ExtractUpper3x3(float * inMat4, float * outMat3) {
	outMat3[ 0] = inMat4[ 0];
	outMat3[ 1] = inMat4[ 1];
	outMat3[ 2] = inMat4[ 2];
	outMat3[ 3] = inMat4[ 4];
	outMat3[ 4] = inMat4[ 5];
	outMat3[ 5] = inMat4[ 6];
	outMat3[ 6] = inMat4[ 8];
	outMat3[ 7] = inMat4[ 9];
	outMat3[ 8] = inMat4[10];
}
bool MAT4_Equal(float * inMat0, float * inMat1) {
	float * m0 = inMat0;
	float * m1 = inMat1;
	for( int i=0; i<16; i++ ) {
		if( *m0++ != *m1++ ) {
			return false;
		}
	}
	return true;
}

float MTH_GetFraction(float inF) {
	return inF - (int)inF;
}

void QT_Equate(float * inQ, float * outQ) {
	memcpy(outQ, inQ, sizeof(float)*4);
}

void QT_Set(float inX, float inY, float inZ, float inW, float * outQ) {
	outQ[0] = inX;
	outQ[1] = inY;
	outQ[2] = inZ;
	outQ[3] = inW;
}

void QT_MAT4_MakeQuaternion(float * inMat, float * outQ) {
	float * m = inMat;
	
	float & x = outQ[0];
	float & y = outQ[1];
	float & z = outQ[2];
	float & w = outQ[3];

	float trace = m[0] + m[5] + m[10] + 1;
	float s = 0;
	// if trace is positive then perform instant calculation
	if( trace > 0 ) {
		s = 0.5f / sqrt(trace);
		w = 0.25f / s;
		x = ( m[9] - m[6] ) * s;
		y = ( m[2] - m[8] ) * s;
		z = ( m[4] - m[1] ) * s;
	}
	else {
		int majorColumn = 0;
		if( m[5] > m[majorColumn*5] ) majorColumn = 1;
		if( m[10] > m[majorColumn*5] ) majorColumn = 2;

		switch( majorColumn ) {
			case 0:
				s = sqrt( 1.0f + m[0] - m[5] - m[10] ) * 2.0f;
				x = 0.25f * s;
				y = (m[4] + m[1] ) / s;
				z = (m[2] + m[8] ) / s;
				w = (m[9] - m[6] ) / s;
				break;

			case 1:
				s = sqrt( 1.0f + m[5] - m[0] - m[10] ) * 2.0f;
				x = (m[4] + m[1] ) / s;
				y = 0.25f * s;
				z = (m[9] + m[6] ) / s;
				w = (m[2] - m[8] ) / s;
				break;

			case 2:
				s = sqrt( 1.0f + m[10] - m[0] - m[5] ) * 2.0f;
				x = (m[2] + m[8] ) / s;
				y = (m[9] + m[6] ) / s;
				z = 0.25f * s;
				w = (m[4] - m[1] ) / s;
				break;
		}
	}
}

void QT_MAT4_MakeMatrix(float * inQ, float * outMat) {
	float * m = outMat;
	
	float & x = inQ[0];
	float & y = inQ[1];
	float & z = inQ[2];
	float & w = inQ[3];

	float xx = x * x;
	float xy = x * y;
	float xz = x * z;
	float xw = x * w;

	float yy = y * y;
	float yz = y * z;
	float yw = y * w;

	float zz = z * z;
	float zw = z * w;

	m[0] = 1 - 2 * ( yy + zz );
	m[1] = 2 * ( xy - zw );
	m[2] = 2 * ( xz + yw );
	m[3] = 0;

	m[4] = 2 * ( xy + zw );
	m[5] = 1 - 2 * ( xx + zz );
	m[6] = 2 * ( yz - xw );
	m[7] = 0;

	m[8] = 2 * ( xz - yw );
	m[9] = 2 * ( yz + xw );
	m[10] = 1 - 2 * ( xx + yy );
	m[11] = 0;

	m[12] = 0;
	m[13] = 0;
	m[14] = 0;
	m[15] = 1;
}

void QT_GetAxisAngle(float * inQ, float * outAxis, float outAngle /*rad*/) {
	outAngle = 2.0f*acosf(inQ[3]);
	float sinHalfAngle = sinf(outAngle/2.0f);
	VEC3_Set(inQ[0] / sinHalfAngle, inQ[1] / sinHalfAngle, inQ[2] / sinHalfAngle, outAxis);
}
void QT_SLERP(float * inQ0, float * inQ1, float inT, float * outQ) {

	float * q0 = inQ0;
	float * q1 = inQ1;

	float cosom = q0[0]*q1[0] + q0[1]*q1[1] + q0[2]*q1[2] + q0[3]*q1[3];
	float delta = 1e-10f;

	float adjustedEnd[4];
	if( cosom < 0.0f ) {
		QT_Set(-q1[0], -q1[1], -q1[2], -q1[3], adjustedEnd);
		cosom *= -1.0f;
	}
	else {
		QT_Equate(q1, adjustedEnd);
	}

	float scaleBegin, scaleEnd;

	if( 1.0f-cosom > delta ) { // normal slerp
		float omega = acosf(cosom);
		float sinom = sinf(omega);
		scaleBegin = sinf((1.0f-inT)*omega) / sinom;
		scaleEnd = sinf(inT * omega) / sinom;
	} else { // linear interp because of divide by zero
		scaleBegin = 1.0f - inT;
		scaleEnd = inT;
	}

	QT_Set(
		scaleBegin*q0[0] + scaleEnd*adjustedEnd[0],
		scaleBegin*q0[1] + scaleEnd*adjustedEnd[1],
		scaleBegin*q0[2] + scaleEnd*adjustedEnd[2],
		scaleBegin*q0[3] + scaleEnd*adjustedEnd[3],
		outQ);
}

void FPSCAM_MoveForward(float amount, bool fixedZ, float * inOutViewMat) {
	float offset[4];

	if( fixedZ ) {
	
		offset[0] = inOutViewMat[2];
		offset[1] = inOutViewMat[6];
		offset[2] = 0;
		offset[3] = 0;
		MAT4_VEC4_Multiply(inOutViewMat, offset, offset);
		VEC3_Normalize(offset);
		VEC3_Multiply(offset, amount, offset);

	} else {
		VEC3_Set(0, 0, -amount, offset);
	}
	inOutViewMat[12] += offset[0];
	inOutViewMat[13] += offset[1];
	inOutViewMat[14] += offset[2];
	
}

void FPSCAM_MoveUp(float amount, bool fixedZ, float * inOutViewMat) {
	float offset[3];
	
	if( fixedZ ) {
		MAT4_ExtractCol3(inOutViewMat, 2, offset);
		VEC3_Multiply(offset, -amount, offset);

	} else {
		VEC3_Set(0, -amount, 0, offset);
	}

	inOutViewMat[12] += offset[0];
	inOutViewMat[13] += offset[1];
	inOutViewMat[14] += offset[2];
}

void FPSCAM_StrafeRight(float amount, float * inOutViewMat) {
	float offset[3] = { -amount, 0, 0 };

	inOutViewMat[12] += offset[0];
	inOutViewMat[13] += offset[1];
	inOutViewMat[14] += offset[2];
}

void FPSCAM_LookRight(float amount_deg, bool inFixedUp, float * inOutViewMat) {
    float rotMat[16];
	float rotVec[4];

	if( inFixedUp ) {
		MAT4_ExtractCol3(inOutViewMat, 2, rotVec);
	} else {
		VEC3_Set(0, 1, 0, rotVec);
	}

	MAT4_MakeArbitraryRotation(rotVec[0], rotVec[1], rotVec[2], MTH_DegToRad(-amount_deg), rotMat);
	MAT4_Multiply(rotMat, inOutViewMat, inOutViewMat);
}

void FPSCAM_LookUp(float amount_deg, float * inOutViewMat) {

    float xRotation_mat4[16];
	MAT4_MakeXRotation(-amount_deg, xRotation_mat4);

	MAT4_Multiply(xRotation_mat4, inOutViewMat, inOutViewMat);
}

void FPSCAM_RollRight(float inAmountDeg, float * inOutViewMat) {
    float rotMat[16];

	MAT4_MakeZRotation(-inAmountDeg, rotMat);
	MAT4_Multiply(rotMat, inOutViewMat, inOutViewMat);
}

void GEO_GenerateUnitSphere(std::vector<float> & vertices, std::vector<float> & normals) {
	const int Size = (int)((3.141592654 / .2 + 1)*(2*3.141592654 / .2 + 1)) * 6;
	vertices.resize(Size);
	normals.resize(Size);

	int i = 0;

	float radius = 1;
	for( float phi = 0.2f; phi <= 3.141592654f; phi += 0.2f ) {
		for( float theta = 0.0f; theta <= 2.0f*3.141592654f; theta += 0.2f ) {
			float px = radius * cosf(theta) * sinf(phi-0.2f);
			float py = radius * sinf(theta) * sinf(phi-0.2f);
			float pz = radius * cosf(phi-0.2f);
			float pmagnitude = sqrtf(px*px + py*py + pz*pz);
			
			normals[i] = px/pmagnitude;
			vertices[i++] = px;
			normals[i] = py/pmagnitude;
			vertices[i++] = py;
			normals[i] = pz/pmagnitude;
			vertices[i++] = pz;

            float x = radius * cosf(theta) * sinf(phi);
			float y = radius * sinf(theta) * sinf(phi);
			float z = radius * cosf(phi);
			float magnitude = sqrtf(x*x + y*y + z*z);

			normals[i] = x/magnitude;
			vertices[i++] = x;
			normals[i] = y/magnitude;
			vertices[i++] = y;
			normals[i] = z/magnitude;
			vertices[i++] = z;
		}
	}
	
}

void GEO_GenerateDisc(float inStartAngle, float inEndAngle, float inInnerRadius, float inOuterRadius, float inZ, int inSegments, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords, float * outBoundingCube)
// generate triangle strip for a partial disc.  first vertex is on outer radius
{
	outVertices.resize(inSegments*2 * 3);
	outNormals.resize(outVertices.size());
	outTexCoords.resize(inSegments*2 * 2);
	
	float * v = &outVertices[0];
	float * n = &outNormals[0];
	float * t = &outTexCoords[0];
	
	float angleDiff = -(inEndAngle-inStartAngle)*(3.141592654f/180) / (inSegments-1);
	float angle = -inStartAngle*(3.141592654f/180);

	float * cube = outBoundingCube;
	if( cube ) {
		cube[0] = 99999999.0f;
		cube[1] = cube[0];
		cube[2] = inZ;
		cube[3] = -cube[0];
		cube[4] = -cube[0];
		cube[5] = inZ;
	}

	for( int i=0; i<inSegments; i++ ) {
		float u = 1.0f - (i/(float)(inSegments-1));
		float c = cos(angle);
		float s = sin(angle);
		
		*v++ = inOuterRadius*c;
		*v++ = inOuterRadius*s;
		*v++ = inZ;

		*n++ = 0;
		*n++ = 0;
		*n++ = 1;

		*t++ = u;
		*t++ = 0;

		*v++ = inInnerRadius*c;
		*v++ = inInnerRadius*s;
		*v++ = inZ;
			
		*n++ = 0;
		*n++ = 0;
		*n++ = 1;

		*t++ = u;
		*t++ = 1;

		if( cube ) {
			cube[0] = glm::min(cube[0], glm::min(*(v-3), *(v-6)));
			cube[1] = glm::max(cube[1], glm::min(*(v-3), *(v-6)));
			cube[3] = glm::min(cube[3], glm::min(*(v-2), *(v-5)));
			cube[4] = glm::max(cube[4], glm::min(*(v-2), *(v-5)));
		}

		angle += angleDiff;
	}

}

void GEO_GenerateUnitCircle(int inSegments, std::vector<float> & outVertices) {
    outVertices.resize(inSegments*2);
    for( int i=0; i<inSegments; i++ ) {
        float angle = i/float(inSegments) * 3.141592654f;
        outVertices[i*2+0] = cos(angle);
        outVertices[i*2+1] = sin(angle);
    }
}

void GEO_ExtractFrustumPoints(float * inVPInvertMat, float outFrustumPoints[3*8])
// frustum points are coordinates in world space in this order: NearBottomLeft, NTopL, NTRight, NBR, FarBL, FTL, FTR, FBR
{
	float ndcFrustumPts[] = {
		-1,-1,-1, 1,  -1, 1,-1, 1,  1, 1,-1, 1,  1,-1,-1,1, // near
		-1,-1, 1, 1,  -1, 1, 1, 1,  1, 1, 1, 1,  1,-1, 1, 1 // far
	};

	for( int i=0; i<8; i++ ) {
		float p[4];
		MAT4_VEC4_Multiply(inVPInvertMat, &ndcFrustumPts[i*4], p);
		VEC3_Divide(p, p[3], &outFrustumPoints[i*3]);
	}

}

bool GEO_RayPlaneIntersection(float * ptOnPlane, float * planeNormal, float * rayOrigin, float * rayDir, float * optOutT, float * outIntersection) {
	float * p = ptOnPlane;
	float * n = planeNormal;
	float * o = rayOrigin;
	float d[3];
	VEC3_Normalize(rayDir, d);

	
	float den = VEC3_Dot(n, d);
	if( den == 0 ) return false;

	float vec[3];
	VEC3_Subtract(o, p, vec);
	float num = -VEC3_Dot(n, vec);

	float t = num / den;
	if( optOutT != 0 ) {
		*optOutT = t;
	}
	
	VEC3_Multiply(d, t, vec);
	VEC3_Add(o, vec, outIntersection);

	return true;
}

bool GEO_RayTriangleIntersection(float * inRayOrigin, float * inRayDir, float * inTriangleVertices, float * outT, float * outIntersection) {
	float xVec[3];
	VEC3_Subtract(inTriangleVertices+6, inTriangleVertices+3, xVec);
	VEC3_Normalize(xVec);

	float yVec[3];
	VEC3_Subtract(inTriangleVertices+0, inTriangleVertices+3, yVec);

	float zVec[3];
	VEC3_Cross(xVec, yVec, zVec);
	VEC3_Normalize(zVec);

	VEC3_Cross(zVec, xVec, yVec);

	if( GEO_RayPlaneIntersection(inTriangleVertices, zVec, inRayOrigin, inRayDir, outT, outIntersection) ) {

		float vec[3];
		float perp[3];
		float vec2D[3];

		for( int i=0; i<3; i++ ) {
			VEC3_Subtract(inTriangleVertices+((i+1)%3)*3, inTriangleVertices+i*3, vec);
			
			perp[0] = -VEC3_Dot(vec, yVec);
			perp[1] = VEC3_Dot(vec, xVec);
			perp[2] = 0;
			
			VEC3_Subtract(outIntersection, inTriangleVertices+i*3, vec);
			vec2D[0] = VEC3_Dot(vec, xVec);
			vec2D[1] = VEC3_Dot(vec, yVec);
			vec2D[2] = 0;

			if( VEC3_Dot(perp, vec2D) < 0 ) {
				return false;
			}
		}

		return true;
	}

	return false;
}

void GEO_MakePickRay(float * inViewMat, float * inProjectionMat, int * inViewport, float * inViewPt3, float * outRayOrigin, float * outRayDir) {
	
	float PVInv[16];
	MAT4_Multiply(inProjectionMat, inViewMat, PVInv);
	MAT4_Invert(PVInv, PVInv);

	float ndc[] = {
		(2 * (inViewPt3[0] - inViewport[0]) / inViewport[2]) - 1,
		-((2 * (inViewPt3[1] - inViewport[1]) / inViewport[3]) - 1),
		(2 *  inViewPt3[2] ) - 1,
		1 };

	float worldPt[4];
	MAT4_VEC4_Multiply(PVInv, ndc, worldPt);

	if( worldPt[3] != 0 ) {
		worldPt[0] /= worldPt[3];
		worldPt[1] /= worldPt[3];
		worldPt[2] /= worldPt[3];
		worldPt[3] = 1.0f;
	}

	if( inProjectionMat[15] == 0 ) { // if in a perspective view
		float cameraMat[16];
		MAT4_InvertQuick(inViewMat, cameraMat);

		VEC3_Equate(cameraMat+12, outRayOrigin);

		VEC3_Subtract(worldPt, outRayOrigin, outRayDir);
		//VEC3_Equate(worldPt, outRayDir);
		VEC3_Normalize(outRayDir);

	} else {										// if in an orthographic view
		VEC3_Equate(worldPt, outRayOrigin);
		VEC3_Equate(inViewMat+8, outRayDir);
		VEC3_Negate(outRayDir);
		VEC3_Normalize(outRayDir);
	}


}

void BarycentricTriangleInterpolation(float * inVertices, float * inP, int inNumAttributesPerVertex, float * inAttributes, float * outAttributes) 
// inVertices is the vertices of a 3d triangle [0][1][2] [3][4][5] [6][7][8]
// inP is a 3space point on the triangle [0][1][2]
// inAttributes are floats at each vertex [0--inNumAttributes) [inNumAttributes--2*inNumAttributes) [2*inNumAttributes--3*inNumAttributes-1)
// outAttributes are the interpolated values at each vertex [0..inNumAttributes)
{
	float * t = inVertices;

	float side[3];

	VEC3_Subtract(t+3, t, side);
	float a = VEC3_Magnitude(side);

	VEC3_Subtract(t+6, t+3, side);
	float b = VEC3_Magnitude(side);

	VEC3_Subtract(t, t+6, side);
	float c = VEC3_Magnitude(side);

	VEC3_Subtract(inP, t+0, side);
	float d = VEC3_Magnitude(side);

	VEC3_Subtract(inP, t+3, side);
	float e = VEC3_Magnitude(side);

	VEC3_Subtract(inP, t+6, side);
	float f = VEC3_Magnitude(side);

	float area[3];

	area[2] = 0.25f * sqrt( (a+d+e) * (d+e-a) * (e+a-d) * (a+d-e) );
	
	area[0] = 0.25f * sqrt( (e+b+f) * (b+f-e) * (f+e-b) * (e+b-f) );
	
	area[1] = 0.25f * sqrt( (d+f+c) * (f+c-d) * (c+d-f) * (d+f-c) );
	
	float totalAreaInv = 1.0f / (area[0] + area[1] + area[2]);

	for( int i=0; i<inNumAttributesPerVertex; i++ ) {
		outAttributes[i] = (
				inAttributes[i+inNumAttributesPerVertex*0]*area[0]
				+ inAttributes[i+inNumAttributesPerVertex*1]*area[1]
				+ inAttributes[i+inNumAttributesPerVertex*2]*area[2]) * totalAreaInv;
	}
}

bool GEO_LineLineIntersection(float * inP1, float * inV1, float * inP2, float * inV2, bool inSegmentIntersection, bool & outParallel, float & outT1, float & outT2, float * outIntersection)
//   Determine the intersection point of two line segments
//   Return FALSE if the lines don't intersect
// original code: http://paulbourke.net/geometry/lineline2d/
{
	outParallel = false;
	outT1 = 0;
	outT2 = 0;

	float * p1 = inP1;
	float * v1 = inV1;

	float * p2 = inP2;
	float * v2 = inV2;

	float dx = p1[0]-p2[0];
	float dy = p1[1]-p2[1];

	float denom  = v2[1] * v1[0] - v2[0] * v1[1];
	float numera = v2[0] * dy - v2[1] * dx;
	float numerb = v1[0] * dy - v1[1] * dx;

	float EPS = 1e-4f;

	// Are the line coincident?
	if (fabs(numera) < EPS && fabs(numerb) < EPS && fabs(denom) < EPS) {
		outIntersection[0] = (p1[0] + p2[0]) * 0.5f;
		outIntersection[1] = (p1[1] + p2[1]) * 0.5f;
		outParallel = true;
		return true;
	}

	// Are the line parallel
	if (fabs(denom) < EPS) {
		outIntersection[0] = 0;
		outIntersection[1] = 0;
		outParallel = true;
		return true;
	}

	// Is the intersection along the the segments
	outT1 = numera / denom;
	outT2 = numerb / denom;
	if( inSegmentIntersection && (outT1 < 0 || outT1 > 1 || outT2 < 0 || outT2 > 1) ) {
		outIntersection[0] = 0;
		outIntersection[1] = 0;
		return false;
	}

	outIntersection[0] = p1[0] + outT1 * inV1[0];
	outIntersection[1] = p1[1] + outT1 * inV1[1];

	return true;
}
int GEO_BestFitRectInRect(float * inFlexibleRect, float * inFixedRect, float * outBestFitRect) 
// rect format is x, y, w, h
{
	int errorCode = 0;

	float * r1 = inFlexibleRect;
	float * r2 = inFixedRect;
	float * r3 = outBestFitRect;

	if( r1[3] == 0 ) {
		errorCode = 1;
	} else if( r1[2] == 0 ) {
		errorCode = 2;
	} else if( r2[2] == 0 ) {
		errorCode = 3;
	} else if( r2[3] == 0 ) {
		errorCode = 4;
	} else {

		float aspect1 = r1[2] / (float)r1[3];

		float wRatio = r2[2] / (float)r1[2];
		float hRatio = r2[3] / (float)r1[3];

		if( wRatio < hRatio ) {
			r3[2] = r2[2];
			r3[3] = r2[2] / aspect1;
		} else {
			r3[3] = r2[3];
			r3[2] = r2[3] * aspect1;
		}

		float center[] = { r2[0]+0.5f*r2[2], r2[1]+0.5f*r2[3] };
		r3[0] = center[0] - r3[2]*0.5f;
		r3[1] = center[1] - r3[3]*0.5f;
	}

	return errorCode;
}

void GEO_GenerateUnitRectangle(std::vector<float> & outVertices, std::vector<float> & outTexCoords) {
	
	float v[] = { -1,-1,0, 1,-1,0, -1,1,0, 1,1,0 }; // triangle strip
	outVertices.resize(12);
	memcpy(&outVertices[0], v, sizeof(float)*12);

	float uv[] = { 0,0, 1,0, 0,1, 1,1 }; // triangle strip
	outTexCoords.resize(8);
	memcpy(&outTexCoords[0], uv, sizeof(float)*8);

}

void GEO_GenerateRectangle(float inWidth, float inHeight, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords) 
// this function generates vertex attributes of a ccw triangle strip that makes a rectangle, centered.
{
    const float w = inWidth/2;
    const float h = inHeight/2;
    
    float v[] = { -w,-h,0, w,-h,0, -w,h,0, w,h,0 }; // triangle strip
	outVertices.resize(12);
	memcpy(&outVertices[0], v, sizeof(float)*12);
    
    float n[] = { 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1 };
    outNormals.resize(12);
    memcpy(&outNormals[0], n, sizeof(float)*12);
    
	float uv[] = { 0,1, 1,1, 0,0, 1,0 }; // triangle strip
	outTexCoords.resize(8);
	memcpy(&outTexCoords[0], uv, sizeof(float)*8);

}


void GL_WindowPtToWorld(float * inWindowPt, float * inModelviewMat, float * inProjectionMat, int * inViewport, float * outWorldPt)
// return - a point converted into world space (on the near clipping plane if windowPt.z == 0)
{
	float PM[16];  // proj * modelview
	MAT4_Multiply(inProjectionMat, inModelviewMat, PM);

	float invPM[16];
	MAT4_Invert(PM, invPM);

	float ndc[] = {  // normalized device coords
		2 * (inWindowPt[0] - inViewport[0]) / inViewport[2] - 1,
		-(2 * (inWindowPt[1] - inViewport[1]) / inViewport[3] - 1),
		2 * inWindowPt[2] - 1,
		1 };

	float worldPt[4];
	MAT4_VEC4_Multiply(invPM, ndc, worldPt);

	if( worldPt[3] != 0 ) {  // if we can prevent a divide by zero
		float scale = 1.0f / worldPt[3];
		VEC3_Multiply(worldPt, scale, outWorldPt);
	}

}

// ------------- Begin OS specific wrapper functions ------------------

int OS_GetCurrentMillisecond() {
	return 0;
}

bool OS_ReadBinaryFile(const std::string & inFilename, void * outStream, int inBytes) 
// outputs the content of a binary file to outStream.  returns true on success
{

    std::ifstream in(inFilename.c_str(), std::ios::binary);
	if( !in.is_open() ) return false;
		
	in.read((char *)outStream, inBytes);
	in.close();

	return true;
}

// initializes the imageinfo struct.   ownership of image is transferred to the imageInfo.
ImageInfo::ImageInfo(int width, int height, int bitDepth, int rowBytes, unsigned char * image) {
	this->texWidth = width;
	this->texHeight = height;
	this->bitDepth = bitDepth;
	this->rowBytes = rowBytes;
	this->image = image;
	texWidth = width; 
	texHeight = height;
}




