<?php

namespace App\Http\Controllers\Api\V1;

use App\DTO\ApiResponseDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\CreateSimOrderRequest;
use App\Http\Requests\Api\V1\ListPhysicalSimOrdersRequest;
use App\Http\Requests\Api\V1\ReserveMsisdnRequest;
use App\Http\Requests\Api\V1\UpdateSimOrderRequest;
use App\Services\GetMyNumberService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class GetMyNumberController extends Controller
{
    protected GetMyNumberService $getMyNumberService;


    public function __construct(GetMyNumberService $getMyNumberService)
    {
        $this->getMyNumberService = $getMyNumberService;
    }
    public function reserveMsisdn(ReserveMsisdnRequest $request): ApiResponseDTO
    {
        $msisdn = $request->getMsisdn();
        $response = $this->getMyNumberService->reserveMsisdn($msisdn);

        if ($response) {
            return ApiResponseDTO::from([
                'code' => Response::HTTP_OK,
                'message' => 'Successfully reserved msisdn',
                'data' => $response
            ]);
        }

        return ApiResponseDTO::from([
            'code' => Response::HTTP_BAD_REQUEST,
            'message' => 'Failed to reserve msisdn'
        ]);
    }

    public function storeSimOrder(CreateSimOrderRequest $request): ApiResponseDTO
    {
        $validatedData = $request->getValidatedData();
        return $this->getMyNumberService->storeSimOrder($validatedData);
    }

    public function updatePhysicalSimOrder(UpdateSimOrderRequest $request): ApiResponseDTO
    {
        $correlationId = $request->getCorrelationId();
        $status = $request->getStatus();
        return $this->getMyNumberService->updatePhysicalSimOrder($correlationId, $status);
    }


    public function listPhysicalSimOrders(ListPhysicalSimOrdersRequest $request): ApiResponseDTO
    {
        $perPage = $request->getPerPage();
        $page = $request->getPage();
        list($data, $meta) = $this->getMyNumberService->listPhysicalSimOrders($perPage, $page);
        if($data){
            return ApiResponseDTO::from([
                'code' => Response::HTTP_OK,
                'message' => 'Successfully retrieved physical sim orders',
                'data' => $data,
                'meta' => $meta
            ]);
        }
        return ApiResponseDTO::from([
            'code' => Response::HTTP_NO_CONTENT,
        ]);
    }
    public function getPhysicalSimOrder(string $correlation_id): ApiResponseDTO
    {
        if($correlation_id){
            $order = $this->getMyNumberService->getPhysicalSimOrder($correlation_id);
            return ApiResponseDTO::from([
                'code' => Response::HTTP_OK,
                'data' => $order,
            ]);
        }

        return ApiResponseDTO::from([
            'code' => Response::HTTP_NO_CONTENT,
        ]);
    }


    public function getPaymentStatus(Request $request): ApiResponseDTO
    {
        $msisdn = $request->query('msisdn');
        $correlationId = $request->query('correlation_id');
        return $this->getMyNumberService->getPaymentStatus($msisdn, $correlationId);
    }
    public function getSimCreationStatus(Request $request): ApiResponseDTO
    {
        $msisdn = $request->query('msisdn');
        $correlationId = $request->query('correlation_id');
        return $this->getMyNumberService->getPaymentStatus($msisdn, $correlationId);
    }

}
